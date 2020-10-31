# Build aws-iam-authenticator
FROM golang:1.13 AS aws-iam-authenticator
LABEL stage=intermediate

ARG AWS_AUTHENTICATOR_VERSION=0.4.0

ARG GORELEASER=0.123.2

# Install prerequisites
RUN curl -s -L --retry 8 -o /tmp/goreleaser.tgz https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER}/goreleaser_Linux_x86_64.tar.gz \
    && tar -xzvf /tmp/goreleaser.tgz -C /tmp/ \
    && mv /tmp/goreleaser /usr/local/bin

RUN go get -u sigs.k8s.io/aws-iam-authenticator/cmd/aws-iam-authenticator

WORKDIR /go/src/sigs.k8s.io/aws-iam-authenticator

RUN make build || true



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
    # CLEAN UP
    && apk del --purge deps \
    && rm -rf /tmp/*

# Copy aws iam authenticator
COPY --from=aws-iam-authenticator /go/src/sigs.k8s.io/aws-iam-authenticator/dist/authenticator_linux_amd64/aws-iam-authenticator /usr/local/bin
