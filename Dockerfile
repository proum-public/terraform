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



# Build terraform
FROM golang:1.13 AS terraform
LABEL stage=intermediate

ARG TERRAFORM_VERSION=v0.13.4
ARG GO111MODULE=on

RUN go get github.com/hashicorp/terraform@${TERRAFORM_VERSION}

WORKDIR /go/src/github.com/hashicorp/terraform



FROM alpine:3.12

MAINTAINER Hauke Mettendorf <hauke.mettendorf@gmail.com>

ARG AWS_CLI_VERSION=2.0.53

RUN apk --update --no-cache add \
    bash \
    ca-certificates \
    openssl \
    py-pip \
    wget \
    openssh \
    libc6-compat \
    && apk add --update -t deps wget \
    # INSTALL AWS CLI
    && pip install awscli==${AWS_CLI_VERSION} \
    # CLEAN UP
    && apk del --purge deps \
    && rm /var/cache/apk/* \
    && rm -rf /tmp/*

# Copy aws iam authenticator
COPY --from=aws-iam-authenticator /go/src/sigs.k8s.io/aws-iam-authenticator/dist/authenticator_linux_amd64/aws-iam-authenticator /usr/local/bin

# Copy terraform
COPY --from=terraform /go/bin/terraform /usr/local/bin/terraform
