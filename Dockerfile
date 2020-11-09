########################################################
# TERRAFORM LIBVIRT PLUGIN BUILDER
########################################################
FROM golang:1.13-alpine3.12 as terraform-libvirt-builder

ARG GOPATH=/build
ARG GOBIN=/usr/local/go/bin
ARG GO111MODULE=on

RUN mkdir -p /build/src

RUN apk --no-cache add \
    git \
    openssh \
    make \
    libvirt-dev \
    gcc \
    libc-dev

RUN cd ${GOPATH}/src \
    && git clone https://github.com/dmacvicar/terraform-provider-libvirt.git \
    && cd $GOPATH/src/terraform-provider-libvirt \
    && go list -m all \
	&& make \
	&& chmod a+x terraform-provider-libvirt \
	&& cp terraform-provider-libvirt /tmp

########################################################
# MAIN IMAGE
########################################################
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
    # Terraform plugins
    && mkdir -p /usr/local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64 \
    # QEMU
    && apk --no-cache add \
    qemu-system-x86_64 \
    qemu-img \
    libvirt \
    # CLEAN UP
    && apk del --purge deps \
    && rm -rf /tmp/*

COPY --from=terraform-libvirt-builder /tmp/terraform-provider-libvirt /usr/local/share/terraform/plugins/registry.terraform.io/dmacvicar/libvirt/0.6.2/linux_amd64

CMD ["terraform"]