FROM alpine AS builder-xray

# BuildKit 的自动变量
ARG TARGETPLATFORM
# 使用源
ARG RELEASE_ACCOUNT

RUN set -eux; \
    apk update; \
    apk add --no-cache \
        curl \
        wget \
        gzip \
        unzip \
        bash \
        tree \
        ;

COPY pre_bin.sh /usr/src/pre_bin.sh

RUN set -eux; \
	cd /usr/src/; \
	chmod +x /usr/src/pre_bin.sh; \
	ls -al /usr/src/; \
	TARGETPLATFORM=${TARGETPLATFORM} RELEASE_ACCOUNT=${RELEASE_ACCOUNT} ./pre_bin.sh; \
    tree /usr/opt/;

FROM alpine AS dist

WORKDIR /

RUN set -eux; \
    apk update; \
    apk add --no-cache \
        tzdata \
        ;

COPY --from=builder-xray /usr/opt/core/xray /usr/local/bin/core
COPY --from=builder-xray /usr/opt/asset/geoip.dat /usr/local/share/core/geoip.dat
COPY --from=builder-xray /usr/opt/asset/geosite.dat /usr/local/share/core/geosite.dat
COPY config-simple.json /usr/local/etc/core/config.json

ENV TZ=Asia/Shanghai
ENV LC_TIME=C.UTF-8

# xray.location.asset -> XRAY_LOCATION_ASSET
ENV XRAY_LOCATION_ASSET=/usr/local/share/core
# xray.location.confdir -> XRAY_LOCATION_CONFDIR | -confdir
ENV XRAY_LOCATION_CONFDIR=/usr/local/etc/core

# 设置容器启动命令
ENTRYPOINT ["/usr/local/bin/core"]

# 设置容器启动命令(ENTRYPOIN[]的默认参数)
CMD []
