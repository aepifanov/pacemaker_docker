FROM phusion/baseimage:latest

MAINTAINER Andrey Epifanov <andrey@epifanov.net>

ENV HOME /mnt/baseimage/pacemaker/image
ADD . /build

RUN /build/install_pacemaker.sh && \
    /build/cleanup.sh

CMD ["/sbin/my_init"]
