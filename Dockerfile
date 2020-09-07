FROM nginx:stable

LABEL author="Marco Pompili"

RUN apt-get -qq update && \
    apt-get -qy install nginx-extras fail2ban && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN touch /var/log/auth.log

RUN mkdir /run/fail2ban

COPY startup /usr/local/bin/startup

CMD [ "/usr/local/bin/startup" ]

