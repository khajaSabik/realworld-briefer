#!/bin/bash
set -e

ENVIRONMENT=$1
BACKEND_IMAGE=$2
FRONTEND_IMAGE=$3

echo "🚀 Starting deployment process..."
echo "📍 Environment: $ENVIRONMENT"
echo "🐳 Backend Image: $BACKEND_IMAGE"
echo "🐳 Frontend Image: $FRONTEND_IMAGE"

# Create namespace if not exists
echo "📦 Creating namespace..."
kubectl create namespace app-stack-$ENVIRONMENT --dry-run=client -o yaml | kubectl apply -f -

# Apply configurations
echo "⚙️ Applying configurations..."
kubectl apply -f kubernetes/base/secrets.yaml -n app-stack-$ENVIRONMENT
kubectl apply -f kubernetes/base/configmap-backend.yaml -n app-stack-$ENVIRONMENT
kubectl apply -f kubernetes/base/configmap-frontend.yaml -n app-stack-$ENVIRONMENT
kubectl apply -f kubernetes/base/db-pvc.yaml -n app-stack-$ENVIRONMENT
kubectl apply -f kubernetes/base/db-deployment.yaml -n app-stack-$ENVIRONMENT

# Wait for database
echo "⏳ Waiting for database to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n app-stack-$ENVIRONMENT --timeout=180s

# Update backend image
echo "🔄 Deploying backend with image: $BACKEND_IMAGE"
cat kubernetes/base/backend-deployment.yaml | \
  sed "s|khajasabik/realworld-example:backend-latest|$BACKEND_IMAGE|g" | \
  kubectl apply -n app-stack-$ENVIRONMENT -f -

# Apply backend service
kubectl apply -f kubernetes/base/backend-service.yaml -n app-stack-$ENVIRONMENT

# Update frontend image
echo "🔄 Deploying frontend with image: $FRONTEND_IMAGE"
cat kubernetes/base/frontend-deployment.yaml | \
  sed "s|khajasabik/realworld-example:frontend-latest|$FRONTEND_IMAGE|g" | \
  kubectl apply -n app-stack-$ENVIRONMENT -f -

# Apply frontend services
kubectl apply -f kubernetes/base/frontend-service.yaml -n app-stack-$ENVIRONMENT
kubectl apply -f kubernetes/base/frontend-nodeport.yaml -n app-stack-$ENVIRONMENT

# Apply ingress if exists
if [ -f "kubernetes/base/ingress.yaml" ]; then
  kubectl apply -f kubernetes/base/ingress.yaml -n app-stack-$ENVIRONMENT
fi

# Wait for rollouts
echo "⏳ Waiting for deployments to complete..."
kubectl rollout status deployment/backend -n app-stack-$ENVIRONMENT --timeout=300s
kubectl rollout status deployment/frontend -n app-stack-$ENVIRONMENT --timeout=300s

echo "✅ Deployment completed successfully!"

# Display deployment information
echo ""
echo "📊 DEPLOYMENT SUMMARY"
echo "===================="
echo "Environment: $ENVIRONMENT"
echo "Namespace: app-stack-$ENVIRONMENT"
echo "Backend Image: $BACKEND_IMAGE"
echo "Frontend Image: $FRONTEND_IMAGE"
echo ""

echo "🐳 POD DETAILS"
echo "=============="
kubectl get pods -n app-stack-$ENVIRONMENT -o wide

echo ""
echo "🔧 SERVICES"
echo "==========="
kubectl get svc -n app-stack-$ENVIRONMENT

echo ""
echo "🌐 ACCESS INSTRUCTIONS"
echo "======================"
echo "To access your application:"
echo "1. minikube service frontend-nodeport -n app-stack-$ENVIRONMENT --url"
echo "2. Or use: kubectl port-forward service/frontend-service 8080:80 -n app-stack-$ENVIRONMENT"
echo "3. Then visit: http://localhost:8080"

echo ""
echo "📝 LOGS COMMANDS"
echo "================"
echo "Backend logs: kubectl logs -l app=backend -n app-stack-$ENVIRONMENT"
echo "Frontend logs: kubectl logs -l app=frontend -n app-stack-$ENVIRONMENT"
echo "Database logs: kubectl logs -l app=postgres -n app-stack-$ENVIRONMENT"