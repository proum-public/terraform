FROM alpine:3.12

LABEL \
  maintainer="Hauke Mettendorf <hauke@mettendorf.it>" \
  org.opencontainers.image.title="terraform" \
  org.opencontainers.image.description="A simple alpine based container for building Terraform based infrastructure" \
  org.opencontainers.image.authors="Hauke Mettendorf <hauke@mettendorf.it>" \
  org.opencontainers.image.url="https://gitlab.com/proum-public/docker/terraform" \
  org.opencontainers.image.vendor="https://mettendorf.it" \
  org.opencontainers.image.licenses="GNUv2"

ARG AWS_CLI_VERSION=1.18.169
ARG AWS_IAM_AUTHENTICATOR_VERSION=0.5.2
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
    # INSTALL AWS CLI
    && pip install awscli==${AWS_CLI_VERSION} \
    && git clone https://github.com/tfutils/tfenv.git /opt/tfenv \
    # Terraform
    && tfenv install ${TERRAFORM_VERSION} \
    && tfenv use ${TERRAFORM_VERSION} \
    # AWS Authenticator
    && curl -sL https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64 -o /usr/bin//aws-iam-authenticator \
    && chmod +x /usr/bin/aws-iam-authenticator \
    # CLEAN UP
    && apk del --purge deps \
    && rm -rf /tmp/*
