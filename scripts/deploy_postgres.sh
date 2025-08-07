#!/bin/bash

# Deploy single PostgreSQL instance
set -euo pipefail

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    --token)
      TOKEN="$2"
      shift 2
      ;;
    --values-file)
      VALUES_FILE="$2"
      shift 2
      ;;
    --release-name)
      RELEASE_NAME="$2"
      shift 2
      ;;
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "Deploying single PostgreSQL instance..."

# Generate release name if not provided
if [ -z "${RELEASE_NAME:-}" ]; then
  RELEASE_NAME="pg-$(echo -n "${{ github.event.repository.name }}" | md5sum | cut -c 1-8)"
fi

# Deploy using Helm chart for single PostgreSQL
# This would use a different chart than Crunchy
helm upgrade --install "$RELEASE_NAME" \
  --namespace "$NAMESPACE" \
  --values "$VALUES_FILE" \
  ./charts/postgres

echo "database_type=single" >> $GITHUB_OUTPUT
echo "release=$RELEASE_NAME" >> $GITHUB_OUTPUT
echo "cluster=$RELEASE_NAME" >> $GITHUB_OUTPUT
