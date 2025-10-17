#!/bin/bash
set -e

ENVIRONMENT=$1
K8S_NAMESPACE="app-stack"

echo "🚀 Deploying to $ENVIRONMENT"
echo "📁 Namespace: ${K8S_NAMESPACE}-${ENVIRONMENT}"

# Create namespace if it doesn't exist
kubectl create namespace ${K8S_NAMESPACE}-${ENVIRONMENT} --dry-run=client -o yaml | kubectl apply -f -

# Deploy using kustomize
kubectl apply -k kubernetes/${ENVIRONMENT}/

echo "✅ Deployment initiated to $ENVIRONMENT"