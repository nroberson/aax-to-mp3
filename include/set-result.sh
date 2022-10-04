# this file should be sourced

function set_success
{
    local value="$*"
    if [ $# -gt 0 ]; then
        printf "$value" > /dev/stdout
    fi

    return 0
}

function set_error
{
    local message="$*"
    if [ $# -gt 0 ];then
        printf "|!| ${message}\n" > /dev/stderr
    fi

    return 42
}


function _foo {

    set_error "asdf"
    return $?
}
