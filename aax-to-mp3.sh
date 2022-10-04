#!/usr/bin/env bash

# ./audible-to-mp3.sh <file.aax> [output dir]
# - Removes DRM and splits Audible books into mp3 files by segment
# - requires curl, ffmpeg, ffprobe, jq, and perl

source ./include/set-result.sh
source ./include/log.sh
source ./include/check-dependencies.sh
source ./include/aax-activation-bytes.sh
source ./include/sanitize-filename.sh


if ! check_dependencies; then
    set_error
    exit $?
fi

###
### entrypoint
###

log "aax-to-mp3.sh"

AAX_IN="$1"
OUT_DIR="${2:-out}"

if [ ! -f "$AAX_IN" ]; then
    echo "input file '$AAX_IN' does not exist!"
    exit 1
fi

##
## Convert aax to one large mp3 file
tmp_mp3="$(mktemp).mp3"
if ! activation_bytes=$(get_activation_bytes "$AAX_IN"); then
    set_error
    exit $?
fi

log "activation bytes: $activation_bytes"

log "re-encoding as mp3"
if ! ffmpeg -y -activation_bytes $activation_bytes \
    -i "$AAX_IN" \
    -codec:a libmp3lame \
    $tmp_mp3; then

    set_error "failed to convert aax to mp3"
    exit $?
fi

##
## read metadata from the aax and dump it into a temp file.
json_info=$(mktemp)
ffprobe -i "$AAX_IN" \
    -show_format \
    -show_chapters \
    -print_format json \
    > "$json_info"

##
## extract book title and fallback to the aax filename if title is null or empty.
book_title=$(jq -r '.format.tags.title' "$json_info")
if [ -z "$book_title" ] || [ "null" = "$book_title" ]; then
    book_title=$(basename -- "$AAX_IN")
    book_title="${book_title%.*}"
fi
book_title=$(sanitize_filename "$book_title")

##
## use the output dir if provided, falling back to book title otherwise.
OUT_DIR="$OUT_DIR/$book_title"
mkdir -p "$OUT_DIR"

##
## build list of ffmpeg copy commands for each chapter
copy_commands=""

# extract chapter start time and end time, and format as one chapter per line.
# - <start_time> <end_time>
chapter_info=$(jq -r '.chapters[] | .start_time + " " + .end_time' "$json_info")

# read each line using a while loop
segment=1
while read start end; do
    title="${book_title}-Segment_${segment}"
    copy_commands="$copy_commands -c copy -metadata title='$title' -ss $start -to $end $OUT_DIR/${title}.mp3"

    ((segment++))
done <<<"$chapter_info"

##
## split large mp3 into per-chapter mp3 files
ffmpeg -i $tmp_mp3 $copy_commands

rm -f "$json_info"
rm -f "$tmp_mp3"
