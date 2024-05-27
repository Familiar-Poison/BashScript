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

    ```

    * **disk_check.sh:**

    ```

    ```

