ARG VERSION=stable-alpine
FROM nginx:${VERSION} as builder

LABEL maintainer="emarcs"
LABEL email="docker@mg.odd.red"

ENV MORE_HEADERS_VERSION=0.33
ENV MORE_HEADERS_REPO=openresty/headers-more-nginx-module

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
    wget \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    libedit-dev \
    mercurial \
    bash \
    alpine-sdk \
    findutils

RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
    wget "https://github.com/${MORE_HEADERS_REPO}/archive/v${MORE_HEADERS_VERSION}.tar.gz" -O extra_module.tar.gz

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN rm -rf /usr/src/nginx /usr/src/extra_module && mkdir -p /usr/src/nginx /usr/src/extra_module && \
    tar -zxC /usr/src/nginx -f nginx.tar.gz && \
    tar -xzC /usr/src/extra_module -f extra_module.tar.gz

WORKDIR /usr/src/nginx/nginx-${NGINX_VERSION}

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') && \
    sh -c "./configure --with-compat $CONFARGS --add-dynamic-module=/usr/src/extra_module/*" && make modules

# Production container starts here
FROM nginx:${VERSION}

RUN apk add --no-cache --update bind-tools dumb-init

COPY --from=builder /usr/src/nginx/nginx-${NGINX_VERSION}/objs/*_module.so /etc/nginx/modules/

RUN wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker -O /usr/local/bin/install-ngxblocker; \
    chmod +x /usr/local/bin/install-ngxblocker; mkdir -p /etc/nginx/sites-available

COPY default.conf /etc/nginx/sites-available

VOLUME ["/etc/nginx/sites-available"]

RUN  /usr/local/bin/install-ngxblocker -x

EXPOSE 443

COPY config.sh /
COPY start.sh /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["sh", "-c", "/config.sh && /start.sh"]

