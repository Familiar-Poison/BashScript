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
}

email () {
    if [ -z "$email_recipient" ]; then
        echo "Report Status: No email recipient found."

    else
        current_datetime=$(date +'%Y%m%d %H:%M')
        email_subject="$current_datetime disk_check - critical"
        email_content="$DISK_PARTITION_CRITICAL"
        echo -e "Subject: $email_subject\n$email_content" | msmtp "$email_recipient"
        echo "Report Status: Email report sent."
    fi
    
}


main () {

    # #df -h
    # thresholds=105
    # # DISK_PARTITION=$( df -P | awk '0+$5 >= 75 {print $1}')
    # # DISK_PARTITION=$( df -P | awk '0+$5 >= $thresholds {print}')
    # DISK_PARTITION=$(df -P | awk -v thresholds="$thresholds" 'NR > 1 && 0+$5 >= thresholds {print}')
    # echo "$DISK_PARTITION"

    # exit 0
    

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

    # #df -h
    # thresholds=105
    # # DISK_PARTITION=$( df -P | awk '0+$5 >= 75 {print $1}')
    # # DISK_PARTITION=$( df -P | awk '0+$5 >= $thresholds {print}')
    # DISK_PARTITION=$(df -P | awk -v thresholds="$thresholds" 'NR > 1 && 0+$5 >= thresholds {print}')
    # echo "$DISK_PARTITION"

    # exit 0

    DISK_PARTITION_WARNING=$(df -P | awk -v thresholds="$WARNING_THRESHOLD" 'NR > 1 && 0+$5 >= thresholds {print}')
    DISK_PARTITION_CRITICAL=$(df -P | awk -v thresholds="$CRITICAL_THRESHOLD" 'NR > 1 && 0+$5 >= thresholds {print}')


    if [ -z "$DISK_PARTITION_WARNING" ] && [ -z "$DISK_PARTITION_CRITICAL" ]; then
        echo "Usage is still within threshold"
        exit 0

    elif [ -n "$DISK_PARTITION_WARNING" ] && [ -z "$DISK_PARTITION_CRITICAL" ]; then
        echo "Warning threshold has been reached!"
        echo "$DISK_PARTITION_WARNING"
        exit 1

    elif [ -n "$DISK_PARTITION_CRITICAL" ]; then
        echo "Critical threshold has been reached!"
        echo "$DISK_PARTITION_CRITICAL"
        email
        exit 2
    
    fi    

    
    
}


main "$@"
# echo "Exit code $?"