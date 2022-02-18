ARG NGINX_VERSION=1.19.2

FROM nginx:$NGINX_VERSION

ARG NGINX_VERSION=1.19.2
ARG GEOIP2_VERSION=3.3

COPY ./config/geoip2.conf /tmp/geoip2.conf
COPY GeoLite2-Country_20220201.tar.gz /tmp/GeoLite2-Country_20220201.tar.gz 
COPY GeoLite2-City_20220208.tar.gz /tmp/GeoLite2-City_20220208.tar.gz 
RUN set -x && mkdir -p /usr/share/geoip \
  && tar xf /tmp/GeoLite2-Country_20220201.tar.gz -C /usr/share/geoip --strip 1 \
  && tar xf /tmp/GeoLite2-City_20220208.tar.gz -C /usr/share/geoip --strip 1 \
  && ls -al /usr/share/geoip/  
  

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        libpcre++-dev \
        zlib1g-dev \
        libgeoip-dev \
        libmaxminddb-dev \
        wget \
        git

RUN cd /opt \
    && git clone --depth 1 -b $GEOIP2_VERSION --single-branch https://github.com/leev/ngx_http_geoip2_module.git \
    && wget -O - http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar zxfv - \
    && mv /opt/nginx-$NGINX_VERSION /opt/nginx \
    && cd /opt/nginx \
    && ./configure --with-compat --add-dynamic-module=/opt/ngx_http_geoip2_module \
    && make modules 

FROM nginx:$NGINX_VERSION

COPY --from=0 /opt/nginx/objs/ngx_http_geoip2_module.so /usr/lib/nginx/modules
COPY --from=0 /usr/share/geoip /usr/share/geoip
# COPY --from=0 /tmp/geoip2.conf /etc/nginx/conf.d/geoip2.conf

RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests libmaxminddb0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && chmod -R 644 /usr/lib/nginx/modules/ngx_http_geoip2_module.so \
    && sed -i '1iload_module \/usr\/lib\/nginx\/modules\/ngx_http_geoip2_module.so;' /etc/nginx/nginx.conf