# Base image
FROM centos:7

COPY ./ScriptFiles /mnt/app

RUN curl -o /etc/ssl/certs/ca-certificates.crt https://curl.se/ca/cacert.pem

RUN mv /mnt/app/.msmtprc ~/.msmtprc

RUN yum install -y epel-release
RUN yum install -y msmtp msmtp-mta
RUN chmod 600 ~/.msmtprc
#RUN pip install -r /mnt/app/requirements.txt

#RUN apt-get update && apt-get install -y iputils-ping

# docker build -t python_image https://github.com/Familiar-Poison/TestDocker.git#test

# docker build url#ref:dir where ref is a branch, a tag, or a commit SHA.
# -t = image/tag name
# Github repo needs to be public!