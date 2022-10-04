# this file should be sourced - do not execute directly

function get_os
{
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if ! command -v lsb_release &> /dev/null; then
            set_success linux
            return $?
        fi

        local info=$(lsb_release --description)
        if [[ -n $(echo -n "$info" | grep -i ubuntu) ]]; then
            set_success linux-ubuntu
            return $?
        fi

        if [[ -n $(echo -n "$info" | grep -i debian) ]]; then
            set_success linux-debian
            return $?
        fi

        set_success linux

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        set_success macos
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        set_success msys
    elif [[ "$OSTYPE" == "msys" ]]; then
        set_success msys
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        set_success bsd
    else
        set_error "unknown OSTYPE"
    fi
    return $?
}