# this file should be sourced - do not execute directly

function log
{
    local message="$*"
    printf "|•| $message\n" > /dev/stderr
    return 0
}
