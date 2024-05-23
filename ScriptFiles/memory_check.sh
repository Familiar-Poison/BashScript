#!/usr/bin/env bash

# To use BASH: Use Ubuntu -> /mnt/d/Document/BashScript
# To check exit code -> #echo "Exit code $?"
error () {
  printf '%s\n' "$*"
  exit 1
}

usage () {
    echo "Usage: $0 [-c critical threshold %] [-w warning threshold %] [-e email address]"
    exit 128
    #echo "Exit code $?"
}


critical_exit () {

    exit 2
}

warning_exit () {

    exit 1
}

normal_exit () {

    exit 0
}

main () {
    # free
    TOTAL_MEMORY=$( free | grep Mem: | awk '{ print $2 }')
    USED_MEMORY=$( free | grep Mem: | awk '{ print $3 }')
    FREE_MEMORY=$( free | grep Mem: | awk '{ print $4 }')
    
    USED_PERCENT=$(echo "scale=2; 100 * $USED_MEMORY / $TOTAL_MEMORY" | bc)
    FREE_PERCENT=$(echo "scale=2; 100 * $FREE_MEMORY / $TOTAL_MEMORY" | bc)

    # echo $TOTAL_MEMORY
    # echo $USED_PERCENT
    # echo $FREE_PERCENT

    while getopts ":c:w:e:" opt; do
        case ${opt} in
            c )
                CRITICAL_THRESHOLD=$OPTARG
                ;;
            w )
                WARNING_THRESHOLD=$OPTARG
                ;;
            e )
                email=$OPTARG
                ;;
            \? )
                echo "Invalid option"
                ;;
            : )
                echo "Requires argument"
                ;;
        esac
    done

    shift $((OPTIND -1))

    # Argument checking

    if [ -z "$CRITICAL_THRESHOLD" ] || [ -z "$WARNING_THRESHOLD" ]; then
        echo "Missing argument - critical and warning threshold"
        usage

    elif (( $(echo "$CRITICAL_THRESHOLD < 0 || $CRITICAL_THRESHOLD > 100" | bc -l) )); then
        echo "Warning threshold must be within 0-100%."
        usage

    elif (( $(echo "$WARNING_THRESHOLD < 0 || $WARNING_THRESHOLD > 100" | bc -l) )); then
        echo "Warning threshold must be within 0-100%."
        usage

    elif (( $(echo "$CRITICAL_THRESHOLD < $WARNING_THRESHOLD" | bc -l) )); then
        echo "Critical threshold must be greater than warning threshold." 
        usage

    fi

    # Main logic

    if (( $(echo "$USED_PERCENT > $CRITICAL_THRESHOLD" | bc -l) )); then
        echo "Critical threshold has been reached!"
        critical_exit
    
    elif (( $(echo "$USED_PERCENT > $WARNING_THRESHOLD && $USED_PERCENT " | bc -l) )); then
        echo "Critical threshold has been reached!"
        warning_exit

    fi    

    
}


main "$@"