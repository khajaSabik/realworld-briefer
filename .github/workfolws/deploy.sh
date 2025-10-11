#!/bin/bash
set -e

ENVIRONMENT=$1
IMAGE_TAG=$2

echo "🚀 Deploying to $ENVIRONMENT with tag $IMAGE_TAG"

# Update image tags using kustomize
cd kubernetes/$ENVIRONMENT
kustomize edit set image realworld-backend=$IMAGE_TAG-backend
kustomize edit set image realworld-frontend=$IMAGE_TAG-frontend

# Apply using kustomize
kubectl apply -k .

# Wait for rollout
kubectl rollout status deployment/realworld-backend -n app-stack-$ENVIRONMENT --timeout=300s
kubectl rollout status deployment/realworld-frontend -n app-stack-$ENVIRONMENT --timeout=300s

echo "✅ Deployment completed to $ENVIRONMENT"