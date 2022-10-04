# this file should be sourced - do not execute directly

function get_activation_bytes
{
    log "getting activation bytes"
    ##
    ## attempt to read activation bytes from file
    local activation_bytes_file=./activation_bytes
    local activation_bytes=""
    if [ -f "$activation_bytes_file" ]; then
        local activation_bytes=$(<"$activation_bytes_file")
    fi

    if [ -n "$activation_bytes" ];then
        ## if they exist then just return those
        set_success "$activation_bytes"
        return $?
    fi
    ##
    ## else fetch it from Audible

    # install audible-cli if necessary
    if ! install_audible_cli; then
        set_error "failed to install audible cli"
        return $?
    fi

    if ! audible_cli_is_configured; then
        set_error
        return $?
    fi
    
    log "fetching activation-bytes"
    local activation_bytes=$(bin/audible activation-bytes | tail -n1)
    set_success $activation_bytes | tee "$activation_bytes_file"
    return $?
}

function audible_cli_is_configured
{
    log "checking audible configuration"
    if [ ! -f "$HOME/.audible/config.toml" ]; then
        log "|!!!!!!!!|"
        log 
        log "run audible quickstart and choose login with external browser and follow the instructions and then run this script again"
        log
        log "    bin/audible quickstart"
        set_error "audible cli is not configured."
        return $?
    fi

    log "audible cli is ready"
    set_success
    return $?
}

function install_audible_cli
{
    log "installing audible cli"
    local audible_bin=bin/audible
    if [ -x "$audible_bin" ]; then
        log "bin/audible exists"
        set_success
        return $?
    fi

    local base_url="https://github.com/mkb79/audible-cli/releases/latest/download"
    local tmp_zip="$(mktemp).zip"
    local zip_url=""

    source include/os-detection.sh
    local os=$(get_os)
    log "installing for $os"
    if [[ "linux-debian" == "$os" ]]; then
        local zip_url="${base_url}/audible_linux_debian_11.zip"
    elif [[ "linux-ubuntu" == "$os" ]]; then
        local zip_url="${base_url}/audible_linux_ubuntu_latest.zip"
    elif [[ "macos" == "$os" ]]; then
        local zip_url="${base_url}/audible_mac.zip"
    else
        set_error "cannot install audible-cli for '$os'"
        return $?
    fi

    log "downloading $zip_url"
    if ! curl --no-progress-meter -L --output "$tmp_zip" "$zip_url"; then
        set_error "curl failed: '$zip_url'"
        return $?
    fi

    if ! unzip $tmp_zip audible -d bin 1>/dev/stderr; then
        rm "$tmp_zip"
        set_error "unzip failed: $tmp_zip"
        return $?
    else
        rm "$tmp_zip"
    fi

    if [ -f "$audible_bin" ]; then
        chmod u+x bin/audible
        log "audible cli installed"
        set_success
        return $?
    else
        set_error "failed to install audible cli"
        return $?
    fi
}
