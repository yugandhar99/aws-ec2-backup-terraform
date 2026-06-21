#!/usr/bin/env bash
set -euo pipefail

# Loads local environment variables for Terraform development.
# Usage: source bin/load_env.sh [dev|prod]

ENVIRONMENT="${1:-dev}"
ENV_FILE=".env.${ENVIRONMENT}"

if [[ ! -f "$ENV_FILE" ]]; then
  ENV_FILE=".env"
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "No .env file found. Copy .env.sample to .env if you need local variables."
  return 0 2>/dev/null || exit 0
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

echo "Loaded environment variables from $ENV_FILE"
