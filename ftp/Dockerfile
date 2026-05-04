FROM ubuntu:22.04
RUN apt-get update -qq --fix-missing && apt-get install -y --fix-missing proftpd-basic \
    && useradd -m ftpuser \
    && echo "ftpuser:LabFTP2024!" | chpasswd
COPY proftpd.conf /etc/proftpd/proftpd.conf
EXPOSE 21 21100-21110
CMD ["/usr/sbin/proftpd", "--nodaemon"]
