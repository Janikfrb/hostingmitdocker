# Use the debian:bookworm-slim image with support for multiple architectures
FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

# Metadata labels
LABEL org.opencontainers.image.source="https://github.com/Janikfrb/hostingmitdocker/"
LABEL org.opencontainers.image.licenses="MIT"

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    USER=container \
    HOME=/home/container

# Create a non-root user and link a non-existent directory to the home directory
RUN useradd -m -d /home/container -s /bin/bash $USER \
    && ln -s /home/container /nonexistent

# Update and upgrade base packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install required dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc g++ libgcc-12-dev libc++-dev gdb libc6 git wget curl tar zip unzip binutils xz-utils liblzo2-2 \
        cabextract iproute2 net-tools netcat-traditional telnet libatomic1 libsdl1.2debian libsdl2-2.0-0 \
        libfontconfig1 icu-devtools libunwind8 libssl-dev sqlite3 libsqlite3-dev libmariadb-dev-compat \
        libduktape207 locales ffmpeg gnupg2 apt-transport-https software-properties-common ca-certificates \
        liblua5.3-0 libz3-dev libzadc4 rapidjson-dev tzdata libevent-dev libzip4 libprotobuf32 libfluidsynth3 \
        procps libstdc++6 tini \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Temporary fix for libicu66.1 and libssl1.1 on x86_64 and ARM64 architectures
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then \
        wget http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu66_66.1-2ubuntu2.1_amd64.deb \
        http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb \
        && dpkg -i libicu66_66.1-2ubuntu2.1_amd64.deb libssl1.1_1.1.0g-2ubuntu4_amd64.deb \
        && rm libicu66_66.1-2ubuntu2.1_amd64.deb libssl1.1_1.1.0g-2ubuntu4_amd64.deb; \
    elif [ "$ARCH" = "arm64" ]; then \
        wget http://ports.ubuntu.com/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_arm64.deb \
        && dpkg -i libssl1.1_1.1.1f-1ubuntu2_arm64.deb \
        && rm libssl1.1_1.1.1f-1ubuntu2_arm64.deb; \
    fi

# Set locale to en_US.UTF-8
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8

# Set working directory to the container's home directory
WORKDIR /home/container

# Signal to stop container
STOPSIGNAL SIGINT

# Copy entrypoint script and set execute permissions
COPY --chown=container:container ./debian/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint and default command
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
