FROM ubuntu:18.04
MAINTAINER Yaguang <heut2008@gmail.com>

# Update the system
RUN sed -i 's/archive/cn.archive/' /etc/apt/sources.list && apt-get update

# Install supervisord.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor gnupg firefox x264 fonts-arphic-uming pulseaudio

# Setup sshd
RUN apt-get install -y ssh && \
    mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir /var/run/supervisord && \
    echo 'root:changeme' |chpasswd

COPY supervisord.conf /etc/supervisord.conf

# Install Xpra
RUN wget -qO - http://winswitch.org/gpg.asc | apt-key add - && \
    echo "deb http://winswitch.org/ bionic main" > /etc/apt/sources.list.d/winswitch.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y xpra xvfb xserver-xorg-video-dummy
RUN useradd -g xpra xpra && \
    chsh -s /bin/bash xpra && \
    echo 'xpra:changeme' |chpasswd && \
    mkdir -p /run/user/1000 && \
    mkdir -p /home/xpra && \
    chown xpra /run/user/1000 && \
    chown -R xpra:xpra /home/xpra

ADD http://xpra.org/xorg.conf /home/xpra/xorg.conf
RUN /bin/echo -e "export DISPLAY=:100" > /home/xpra/.profile && chown xpra:xpra /home/xpra/xorg.conf

# Use glxgears as the example application
RUN apt-get install -y --no-install-recommends mesa-utils

COPY start.sh /start.sh


EXPOSE 22

ENTRYPOINT ["/start.sh"]
