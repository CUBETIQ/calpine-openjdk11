FROM cubetiq/calpine-os-linux:latest
LABEL maintainer="sombochea@cubetiqs.com"

# Run as root
USER root

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'
ENV TIMEZ=Asia/Phnom_Penh
RUN echo "Start building the openjdk11..."
RUN mkdir -p /src/cubetiq/build
COPY LICENSE version.txt /src/cubetiq/build/
RUN echo "Starting setting up timezone to ${TIMEZ}..."

# For Alpine
# Setup Timezone
RUN apk update && \
    apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/${TIMEZ} /etc/localtime && \
    echo ${TIMEZ} > /etc/timezone

RUN apk add --no-cache --virtual .build-deps curl binutils zstd \
    && GLIBC_VER="2.31-r0" \
    && ALPINE_GLIBC_REPO="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && GCC_LIBS_URL="https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-10.1.0-2-x86_64.pkg.tar.zst" \
    && GCC_LIBS_SHA256="f80320a03ff73e82271064e4f684cd58d7dbdb07aa06a2c4eea8e0f3c507c45c" \
    && ZLIB_URL="https://archive.archlinux.org/packages/z/zlib/zlib-1%3A1.2.11-3-x86_64.pkg.tar.xz" \
    && ZLIB_SHA256=17aede0b9f8baa789c5aa3f358fbf8c68a5f1228c5e6cba1a5dd34102ef4d4e5 \
    && curl -LfsS https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub \
    && SGERRAND_RSA_SHA256="823b54589c93b02497f1ba4dc622eaef9c813e6b0f0ebbb2f771e32adf9f4ef2" \
    && echo "${SGERRAND_RSA_SHA256} */etc/apk/keys/sgerrand.rsa.pub" | sha256sum -c - \
    && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-${GLIBC_VER}.apk > /tmp/glibc-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-${GLIBC_VER}.apk \
    && curl -LfsS ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk > /tmp/glibc-bin-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-bin-${GLIBC_VER}.apk \
    && curl -Ls ${ALPINE_GLIBC_REPO}/${GLIBC_VER}/glibc-i18n-${GLIBC_VER}.apk > /tmp/glibc-i18n-${GLIBC_VER}.apk \
    && apk add --no-cache /tmp/glibc-i18n-${GLIBC_VER}.apk \
    && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
    && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
    && curl -LfsS ${GCC_LIBS_URL} -o /tmp/gcc-libs.tar.zst \
    && echo "${GCC_LIBS_SHA256} */tmp/gcc-libs.tar.zst" | sha256sum -c - \
    && mkdir /tmp/gcc \
    && zstd -d /tmp/gcc-libs.tar.zst --output-dir-flat /tmp \
    && tar -xf /tmp/gcc-libs.tar -C /tmp/gcc \
    && mv /tmp/gcc/usr/lib/libgcc* /tmp/gcc/usr/lib/libstdc++* /usr/glibc-compat/lib \
    && strip /usr/glibc-compat/lib/libgcc_s.so.* /usr/glibc-compat/lib/libstdc++.so* \
    && curl -LfsS ${ZLIB_URL} -o /tmp/libz.tar.xz \
    && echo "${ZLIB_SHA256} */tmp/libz.tar.xz" | sha256sum -c - \
    && mkdir /tmp/libz \
    && tar -xf /tmp/libz.tar.xz -C /tmp/libz \
    && mv /tmp/libz/usr/lib/libz.so* /usr/glibc-compat/lib \
    && apk del --purge .build-deps glibc-i18n \
    && rm -rf /tmp/*.apk /tmp/gcc /tmp/gcc-libs.tar* /tmp/libz /tmp/libz.tar.xz /var/cache/apk/*

# Remove unused anymore
RUN apk del tzdata
ENV JAVA_VERSION jdk11u
RUN set -eux; \
    apk add --no-cache --virtual .fetch-deps curl; \
    ARCH="$(apk --print-arch)"; \
    case "${ARCH}" in \
    aarch64|arm64) \
    ESUM='69ed078755198e6cfcb0ca7f24a15808e21e5f3ed9d0c9efd162027c9330ae8a'; \
    BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-12-07-10-34/OpenJDK11U-jre_aarch64_linux_hotspot_2020-12-07-10-34.tar.gz'; \
    ;; \
    armhf|armv7l) \
    ESUM='17c21a700424db0a7872c70e1c8cb93f63e00a37dbf41af36f29cd0eb0f408ca'; \
    BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-12-07-10-34/OpenJDK11U-jre_arm_linux_hotspot_2020-12-07-10-34.tar.gz'; \
    ;; \
    ppc64el|ppc64le) \
    ESUM='744d64f5d01dcaa4dcb997b3880dc33d4b67084a4d07e4002a94395c4f1de90b'; \
    BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-12-07-10-34/OpenJDK11U-jre_ppc64le_linux_hotspot_2020-12-07-10-34.tar.gz'; \
    ;; \
    s390x) \
    ESUM='974d076d984e52e6e92b7d05281920549640a39951e09f68bd8c7fe7a15d50b6'; \
    BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-12-07-10-34/OpenJDK11U-jre_s390x_linux_hotspot_2020-12-07-10-34.tar.gz'; \
    ;; \
    amd64|x86_64) \
    ESUM='c6f8c9baab036821f981a903fdfa8a15048301e60ef566fc83b374371ab5eab4'; \
    BINARY_URL='https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk11u-2020-12-07-10-34/OpenJDK11U-jre_x64_linux_hotspot_2020-12-07-10-34.tar.gz'; \
    ;; \
    *) \
    echo "Unsupported arch: ${ARCH}"; \
    exit 1; \
    ;; \
    esac; \
    curl -LfsSo /tmp/openjdk.tar.gz ${BINARY_URL}; \
    echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    apk del --purge .fetch-deps; \
    rm -rf /var/cache/apk/*; \
    rm -rf /tmp/openjdk.tar.gz;

RUN echo "Starting install the fonts and msfonts for this image..."

# Workaround for wrong font configuration in adoptopenjdk
# https://github.com/AdoptOpenJDK/openjdk-build/issues/682
RUN apk update && apk upgrade \
    && apk add --no-cache fontconfig \
    && apk add --no-cache ttf-dejavu \
    # Install windows fonts as well. Not required..
    && apk add --no-cache msttcorefonts-installer \
    && update-ms-fonts && fc-cache -f

RUN echo "All has been completed, enjoy!"
ENV JAVA_HOME=/opt/java/openjdk \
    PATH="/opt/java/openjdk/bin:$PATH"

ENTRYPOINT [ "./entrypoint.sh" ]