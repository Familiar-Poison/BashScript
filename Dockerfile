# Base image
# Something
FROM redhat/ubi9-minimal

COPY ./ScriptFiles /mnt/app

RUN curl -o /etc/ssl/certs/ca-certificates.crt https://curl.se/ca/cacert.pem

# From Github secrets
ARG SMTP_USER
ARG SMTP_PASSWORD

# ENV SMTP_USER=${SMTP_USER}
# ENV SMTP_PASSWORD=${SMTP_PASSWORD}

RUN echo "account default" > ~/.msmtprc && \
    echo "host smtp.gmail.com" >> ~/.msmtprc && \
    echo "port 587" >> ~/.msmtprc && \
    echo "auth on" >> ~/.msmtprc && \
    echo "user $SMTP_USER" >> ~/.msmtprc && \
    echo "password $SMTP_PASSWORD" >> ~/.msmtprc && \
    echo "tls on" >> ~/.msmtprc && \
    echo "tls_starttls on" >> ~/.msmtprc && \
    echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> ~/.msmtprc && \
    echo "from $SMTP_USER" >> ~/.msmtprc && \
    echo "logfile /var/log/msmtp.log" >> ~/.msmtprc


RUN yum install -y epel-release
RUN yum install -y msmtp msmtp-mta
RUN chmod 600 ~/.msmtprc

RUN chmod +x /mnt/app/cpu_check.sh && \
    chmod +x /mnt/app/disk_check.sh && \
    chmod +x /mnt/app/memory_check.sh