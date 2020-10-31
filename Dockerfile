FROM alpine:3.12

LABEL \
  maintainer="Hauke Mettendorf <hauke@mettendorf.it>" \
  org.opencontainers.image.title="terraform" \
  org.opencontainers.image.description="A simple alpine based container for building Terraform based infrastructure" \
  org.opencontainers.image.authors="Hauke Mettendorf <hauke@mettendorf.it>" \
  org.opencontainers.image.url="https://gitlab.com/proum-public/docker/terraform" \
  org.opencontainers.image.vendor="https://mettendorf.it" \
  org.opencontainers.image.licenses="GNUv2"

ARG CLOUD_SDK_VERSION=316.0.0
ARG TERRAFORM_VERSION=0.13.4

ENV PATH=${PATH}:/opt/tfenv/bin:/opt/google-cloud-sdk/bin

RUN apk --no-cache add \
    bash \
    curl \
    ca-certificates \
    openssl \
    python3 \
    py3-pip \
    wget \
    openssh \
    libc6-compat \
    git \
    && apk add --no-cache -t deps wget \
    # Terraform
    && git clone https://github.com/tfutils/tfenv.git /opt/tfenv \
    && tfenv install ${TERRAFORM_VERSION} \
    && tfenv use ${TERRAFORM_VERSION} \
    # GCloud CLI
    && wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar xzf google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz -C /opt \
    && rm google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && ln -s /lib /lib64 \
    && gcloud config set core/disable_usage_reporting true \
    && gcloud --version \
    # CLEAN UP
    && apk del --purge deps \
    && rm -rf /tmp/*
