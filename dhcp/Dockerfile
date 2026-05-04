FROM ubuntu:22.04
RUN apt-get update -qq --fix-missing && apt-get install -y --fix-missing isc-dhcp-server \
    && touch /var/lib/dhcp/dhcpd.leases
COPY dhcpd.conf /etc/dhcp/dhcpd.conf
RUN echo 'INTERFACESv4="eth0"' > /etc/default/isc-dhcp-server
EXPOSE 67/udp 68/udp
CMD ["/usr/sbin/dhcpd","-4","-f","-d","--no-pid","-cf","/etc/dhcp/dhcpd.conf"]
