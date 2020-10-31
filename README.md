# Hashicorp Terraform image with AWS iam authenticator built-in

> A simple ```alpine``` based container for building Terraform based infrastructure

## Quick reference

* Sourcecode:
  [click here](https://gitlab.com/proum-public/docker/terraform)
* Maintainer: [Hauke Mettendorf](https://mettendorf.it/)

## Getting Started

These instructions will cover usage information and for the docker container.

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Container Parameters

This is just a simple tooling image. So there is not much magic!

For example via command line arguments:

```shell script
docker run \
  proum/terraform \
  terraform
```

#### Configuration

* none

#### Volumes

* none

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available,
see the [tags on this repository](https://github.com/your/repository/tags).

## License

This project is licensed under the GNU v2 License -
see the [LICENSE.md](LICENSE.md) file for details.
