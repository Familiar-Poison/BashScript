#!/bin/bash


# To check exit code -> #echo "Exit code $?"

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
    if [ -z "$email_recipient" ]; then
        echo "Report Status: No email recipient found."

    else
        current_datetime=$(date +'%Y%m%d %H:%M')
        email_subject="$current_datetime cpu_check - critical"
        email_content=$(ps aux --sort=-%cpu | awk '{print $1, $2, $3, $11}' | head -n 11 | column -t)
        echo -e "Subject: $email_subject\n$email_content" | msmtp "$email_recipient"
        echo "Report Status: Email report sent."
    fi
    
}


main () {

    # free
    # TOTAL_CPU=$(top -bn1 | grep "Cpu(s)" | \sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | \awk '{print 100 - $1"%"}')
    USED_PERCENT=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    # echo "$TOTAL_CPU"

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
                echo "ERROR: Invalid option"
                usage
                ;;
            : )
                echo "ERROR: Requires option value"
                usage
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

    echo "CPU USAGE: $USED_PERCENT"
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