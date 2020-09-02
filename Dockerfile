FROM nginx:stable

LABEL author="Marco Pompili"

RUN apt-get -qq update && \
    apt-get -qy install nginx-extras fail2ban && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
