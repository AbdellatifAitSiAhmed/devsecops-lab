FROM ubuntu:22.04
RUN apt-get update -qq && apt-get install -y openssh-server && mkdir /var/run/sshd && useradd -m -s /bin/bash etudiant && usermod -p '*' etudiant
COPY sshd_config /etc/ssh/sshd_config
COPY authorized_keys /home/etudiant/.ssh/authorized_keys
RUN mkdir -p /home/etudiant/.ssh && chmod 700 /home/etudiant/.ssh && chmod 600 /home/etudiant/.ssh/authorized_keys && chown -R etudiant:etudiant /home/etudiant/.ssh
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
