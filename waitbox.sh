#!/bin/ash

##############################################
# Functions                                  #
##############################################

usage() {
    echo "Usage: waitbox [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --url string            Target URL"
    echo "  -i, --interval integer      Interval between attempts in seconds (default 5)"
    echo "  -m, --max-attempt integer   Maximum attempts. Set -1 for infinite attempt (default -1)"
    echo "  -h, --help                  Get help for options"
    echo "  -s, --silent                Silent mode"
    echo ""
}

pingfn() {
    result=$(wget --spider -T 2 -S $URL 2>&1)
    if [ $? -eq 0 ]; then
        echo $(echo "$result" | grep 'HTTP/' | awk '{print $2}')
        return 0
    else
        echo "$result"
        return 1
    fi
}

exitfn() {
    log "SIGINT or SIGTERM detected. Exiting with code 1."
    exit
}

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

log() {
    if [ "$SILENT" = false ]; then
        echo "$(timestamp) - $1"
    fi
}

##############################################
# Arguments                                  #
##############################################
URL=""
INTERVAL=""
MAX_ATTEMPT=""
HELP=false
SILENT=false

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

while [ $# -gt 0 ]; do
    case "$1" in
        -u|--url)
            URL="$2"
            shift 2
            ;;

        -i|--interval)
            INTERVAL="$2"
            shift 2
            ;;
        
        -m|--max-attempt)
            MAX_ATTEMPT="$2"
            shift 2
            ;;

        -h|--help)
            HELP=true
            shift
            ;;
        
        -s|--silent)
            SILENT=true
            shift
            ;;
        
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ "$HELP" = true ]; then
    usage
    exit 0
fi

if [[ -z "$URL" ]]; then
    echo "URL is undefined. Give the target URL string with -u or --url option."
    exit 1
fi

if [[ -z "$INTERVAL" ]]; then
    echo "INTERVAL is set to default value of 3 because the value is undefined."
    INTERVAL=5
fi

if [[ -z "$MAX_ATTEMPT" ]]; then
    echo "MAX_ATTEMPT is set to default value of -1 because the value is undefined."
    MAX_ATTEMPT=-1
else
    if [[ $MAX_ATTEMPT == 0 ]]; then
        echo "Invalid MAX_ATTEMPT value. Set the value to a positive number or -1 with --max-attempt option."
        exit 1;
    fi
fi

##############################################
# Main Program                               #
##############################################

trap "exitfn" SIGINT SIGTERM

attempt=1
while true; do
    result=$(pingfn)
    status=$?

    if [ "$status" -eq 0 ] && [ "$result" == "200" ]; then
        log "ok"
        break
    fi

    if [ "$MAX_ATTEMPT" != -1 ] && [ "$attempt" -ge "$MAX_ATTEMPT" ]; then
        log "Exceeded maximum attempts. Exiting with code 1."
        exit 1
    else
        log "Attempt $attempt - $result"
    fi

    sleep $INTERVAL
    let "attempt++"
done

return 0
