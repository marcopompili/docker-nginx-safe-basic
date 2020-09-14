FROM nginx:stable

LABEL maintainer="Marco Pompili"
LABEL email="docker@mg.odd.red"

RUN apt-get -qq update && \
    apt-get -qy install nginx-extras && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
