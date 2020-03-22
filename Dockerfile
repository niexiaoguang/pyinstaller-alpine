ARG ARCH=""
ARG ALPINE_VERSION="3.7"

FROM ${ARCH}python:${ALPINE_VERSION}-alpine

ARG PYINSTALLER_TAG
ENV PYINSTALLER_TAG ${PYINSTALLER_TAG:-"v3.5"}

# Official Python base image is needed or some applications will segfault.
# PyInstaller needs zlib-dev, gcc, libc-dev, and musl-dev
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN apk --update --no-cache add \
    zlib-dev \
    musl-dev \
    libc-dev \
    libffi-dev \
    gcc \
    g++ \
    git \
    pwgen \
    && pip install --upgrade pip -i http://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com

# Install pycrypto so --key can be used with PyInstaller
RUN pip install \
    pycrypto -i http://mirrors.aliyun.com/pypi/simple --trusted-host mirrors.aliyun.com

# Build bootloader for alpine
# RUN git clone --depth 1 --single-branch --branch ${PYINSTALLER_TAG} https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller \
#     && cd /tmp/pyinstaller/bootloader \
#     && CFLAGS="-Wno-stringop-overflow" python ./waf configure --no-lsb all \
#     && pip install .. \
#     && rm -Rf /tmp/pyinstaller

RUN git clone --depth 1 --single-branch --branch ${PYINSTALLER_TAG} https://gitee.com/pampanie/pyinstaller.git /tmp/pyinstaller \
    && cd /tmp/pyinstaller/bootloader \
    && CFLAGS="-Wno-stringop-overflow" python ./waf configure --no-lsb all \
    && pip install .. \
    && rm -Rf /tmp/pyinstaller

RUN apk update \
    && apk add tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone



VOLUME /src
WORKDIR /src

ADD ./bin /pyinstaller
RUN chmod a+x /pyinstaller/*

# ENTRYPOINT ["/pyinstaller/pyinstaller.sh"]
CMD ["/bin/sh/"]
