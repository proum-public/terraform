FROM alpine:3.12

LABEL \
  maintainer="Hauke Mettendorf <hauke@mettendorf.it>" \
  org.opencontainers.image.title="terraform" \
  org.opencontainers.image.description="A simple alpine based container for building Terraform based infrastructure" \
  org.opencontainers.image.authors="Hauke Mettendorf <hauke@mettendorf.it>" \
  org.opencontainers.image.url="https://gitlab.com/proum-public/docker/terraform" \
  org.opencontainers.image.vendor="https://mettendorf.it" \
  org.opencontainers.image.licenses="GNUv2"

ARG TERRAFORM_VERSION=0.13.4

ENV PATH=${PATH}:/opt/tfenv/bin

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
    # CLEAN UP
    && apk del --purge deps \
    && rm -rf /tmp/*
