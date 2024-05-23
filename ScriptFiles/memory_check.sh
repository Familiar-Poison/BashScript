#!/usr/bin/env bash

# To use BASH: Use Ubuntu -> /mnt/d/Document/BashScript
# To check exit code -> #echo "Exit code $?"
error () {
  printf '%s\n' "$*"
  exit 1
}

usage () {

    cat << EOF

    Usage: $0 [OPTIONS]

    Options:
        -c      Critical threshold in %
        -w      Warning threshold in %
        -e      Email address to send the report
EOF

    # echo "Usage: ./$0 [-c critical threshold %] [-w warning threshold %] [-e email address]"
    exit 128
    #echo "Exit code $?"
}

email () {

    current_datetime=$(date +'%Y%m%d %H:%M')
    email_subject="$current_datetime memory_check - critical"
    email_content=$(ps aux --sort=-%mem | awk '{print $1, $2, $4, $11}' | head -n 11 | column -t)
    echo -e "Subject: $email_subject\n$email_content" | msmtp "$email_recipient"
}


main () {

    # free
    TOTAL_MEMORY=$( free | grep Mem: | awk '{ print $2 }')
    USED_MEMORY=$( free | grep Mem: | awk '{ print $3 }')
    FREE_MEMORY=$( free | grep Mem: | awk '{ print $4 }')
    
    USED_PERCENT=$(echo "scale=2; 100 * $USED_MEMORY / $TOTAL_MEMORY" | bc)
    FREE_PERCENT=$(echo "scale=2; 100 * $FREE_MEMORY / $TOTAL_MEMORY" | bc)

    while getopts ":c:w:e:" opt; do
        case ${opt} in
            c )
                CRITICAL_THRESHOLD=$OPTARG
                ;;
            w )
                WARNING_THRESHOLD=$OPTARG
                ;;
            e )
                email_recipient=$OPTARG
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
        echo "ERROR: Missing argument - Critical/Warning threshold"
        usage

    elif (( $(echo "$CRITICAL_THRESHOLD < 0 || $CRITICAL_THRESHOLD > 100" | bc -l) )); then
        echo "ERROR: Critical threshold must be within 0-100%."
        usage

    elif (( $(echo "$WARNING_THRESHOLD < 0 || $WARNING_THRESHOLD > 100" | bc -l) )); then
        echo "ERROR: Warning threshold must be within 0-100%."
        usage

    elif (( $(echo "$CRITICAL_THRESHOLD < $WARNING_THRESHOLD" | bc -l) )); then
        echo "ERROR: Critical threshold must be greater than warning threshold." 
        usage

    fi

    # Main logic

    echo "USED: $USED_PERCENT"
    # echo "CRITICAL: $CRITICAL_PERCENT"
    # echo "WARNING: $WARNING_PERCENT"

    if (( $(echo "$USED_PERCENT >= $CRITICAL_THRESHOLD" | bc -l) )); then
        echo "Critical threshold has been reached!"
        email
        exit 2
    
    elif (( $(echo "$USED_PERCENT >= $WARNING_THRESHOLD && $USED_PERCENT < $CRITICAL_THRESHOLD" | bc -l) )); then
        echo "Warning threshold has been reached!"
        exit 1

    elif (( $(echo "$USED_PERCENT < $WARNING_THRESHOLD" | bc -l) )); then
        echo "Usage is still within threshold"
        exit 0
    fi    

    
    
}


main "$@"
# echo "Exit code $?"