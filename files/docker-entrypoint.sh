#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" ; pwd -P)"

# check prerequisites
for cmd in terraform; do
    command -v ${cmd} > /dev/null || {  echo >&2 "${cmd} must be installed - exiting..."; exit 1; }
done

function usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Initiates Terraform plugin directory with libvirt plugin and starts Terraform"
  echo ""
  echo "        -p --terraform-plugins:      Terraform plugins (default: ~/.terraform/plugins) (ENV: TERRAFORM_PLUGINS)"
  echo "        -i --init-directory:         User unspecific directory with terraform plugins"
  echo "                                     (default: /opt/terraform/plugins) (ENV: TERRAFORM_PLUGINS)"
  echo ""
  echo "Environment variables:"
  echo ""
  echo "        TERRAFORM_PLUGINS            Terraform plugins (default: ~/.terraform/plugins)"
  echo "        INIT_DIRECTORY               User unspecific directory with terraform plugins"
  echo "                                     (default: /opt/terraform/plugins)"
}

CMD=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --terraform-plugins|-p)
        export TERRAFORM_PLUGINS="$2"
        shift
        shift
        ;;
        --init-directory|-i)
        export INIT_DIRECTORY="$2"
        shift
        shift
        ;;
        --help|-h|help)
        usage
        exit 0
        ;;
        *)
        CMD+=( "${1}" )
        shift
    esac
done

if [[ -z ${TERRAFORM_PLUGINS} ]]; then
  export TERRAFORM_PLUGINS=~/.terraform/plugins
fi

if [[ -z ${INIT_DIRECTORY} ]]; then
  export INIT_DIRECTORY=/opt/terraform/plugins
fi

# Create user specific plugin directory
mkdir -p "${TERRAFORM_PLUGINS}"

# Copy init directory content
cp ${INIT_DIRECTORY}/* "${TERRAFORM_PLUGINS}"

# Execute CMD
exec "${CMD[@]}"