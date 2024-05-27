# BashScript

### To test via Docker:
`docker pull familiarpoison/bashcentos:latest`

`docker run -it familiarpoison/bashcentos:latest bash`

*  Script files are located inside "/mnt/app"
```
[root@285f4e27a2ad /]# cd /mnt/app
[root@285f4e27a2ad app]# ls
cpu_check.sh  disk_check.sh  memory_check.sh
```

* Sample output:
    * **cpu_check.sh:**
    
    ```
    [root@285f4e27a2ad app]# ./cpu_check.sh -w 0 -c 0 -e jiongco.jansenfranz@gmail.com
    CPU USAGE: 0.8
    Critical threshold has been reached!
    Report Status: Email report sent.
    ```

    * **memory_check.sh:**

    ```
    [root@285f4e27a2ad app]# ./memory_check.sh -c 7 -w 5 -e jiongco.jansenfranz@gmail.com
    MEMORY USAGE: 7.64
    Critical threshold has been reached!
    Report Status: Email report sent.
    ```

    * **disk_check.sh:**

    ```
    [root@285f4e27a2ad app]# ./disk_check.sh -c 0 -w 0 -e jiongco.jansenfranz@gmail.com
    Critical threshold has been reached!
    overlay         1055762868 11885616 990173780       2% /
    tmpfs                65536        0     65536       0% /dev
    tmpfs              4035620        0   4035620       0% /sys/fs/cgroup
    shm                  65536        0     65536       0% /dev/shm
    /dev/sdd        1055762868 11885616 990173780       2% /etc/hosts
    tmpfs              4035620        0   4035620       0% /proc/acpi
    tmpfs              4035620        0   4035620       0% /sys/firmware
    Report Status: Email report sent.
    ```

* A usage guide will be triggered upon a missing or incorrect parameter:
    ```
    [root@285f4e27a2ad app]# ./cpu_check.sh
    ERROR: Missing argument - Critical/Warning threshold

    Usage: ./cpu_check.sh [OPTIONS]

    Options:
        -c      Critical threshold in %
        -w      Warning threshold in %
        -e      Email address to send the report
    ```
