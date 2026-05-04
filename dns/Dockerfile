FROM ubuntu:22.04
RUN apt-get update -qq && apt-get install -y bind9 bind9utils dnsutils && chown -R bind:bind /etc/bind
COPY named.conf.options /etc/bind/
COPY named.conf.local /etc/bind/
COPY zones/ /etc/bind/zones/
RUN chown -R bind:bind /etc/bind/zones
EXPOSE 53/tcp 53/udp
CMD ["named", "-g", "-u", "bind"]
