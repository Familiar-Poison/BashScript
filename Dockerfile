# Base image
FROM centos:7

COPY ./ScriptFiles /mnt/app

RUN curl -o /etc/ssl/certs/ca-certificates.crt https://curl.se/ca/cacert.pem

# Set environment variables for SMTP credentials
# From Github secrets
ARG SMTP_USER
ARG SMTP_PASSWORD

# ENV SMTP_USER=${SMTP_USER}
# ENV SMTP_PASSWORD=${SMTP_PASSWORD}

#RUN mv /mnt/app/.msmtprc ~/.msmtprc

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
#RUN pip install -r /mnt/app/requirements.txt

#RUN apt-get update && apt-get install -y iputils-ping

# docker build -t python_image https://github.com/Familiar-Poison/TestDocker.git#test

# docker build url#ref:dir where ref is a branch, a tag, or a commit SHA.
# -t = image/tag name
# Github repo needs to be public!