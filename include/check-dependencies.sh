# this file should be sourced - do not execute directly

function check_dependencies
{
    if ! command -v ffmpeg &> /dev/null; then
        set_error "ffmpeg could not be found!"
        return $?
    fi

    if ! command -v ffprobe &> /dev/null; then
        set_error "ffprobe could not be found!"
        return $?
    fi

    if ! command -v jq &> /dev/null; then
        set_error "jq could not be found!"
        return $?
    fi

    if ! command -v curl &> /dev/null; then
        set_error "curl could not be found!"
        return $?
    fi

    if ! command -v perl &> /dev/null; then
        set_error "perl could not be found!"
        return $?
    fi
}
