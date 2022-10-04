# this file should be sourced - do not execute directly

function sanitize_filename 
{
    printf '%s' "$@" | perl -pe 's/[\?\[\]\/\\=<>:;,''"&\$#*()|~`!{}%+]//g;' -pe 's/[\r\n\t -]+/-/g;'
}