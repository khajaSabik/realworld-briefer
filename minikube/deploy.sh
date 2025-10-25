#!/bin/bash

echo "🚀 Deploying Complete Application Stack..."

# Create namespace first
echo "1. Creating namespace..."
kubectl create namespace app-stack --dry-run=client -o yaml | kubectl apply -f -

# Apply all YAML files in the current directory to the namespace
echo "2. Deploying all components..."
for file in *.yaml; do
    if [ -f "$file" ]; then
        echo "   Applying $file..."
        kubectl apply -f "$file" -n app-stack
    fi
done

echo "3. Waiting for database to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n app-stack --timeout=180s

echo "4. Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n app-stack --timeout=180s

echo "5. Waiting for Frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n app-stack --timeout=180s

echo "⏳ Waiting for all components to stabilize..."
sleep 30

echo "✅ Deployment Complete!"
echo ""
echo "📊 Current Status:"
kubectl get all -n app-stack

echo ""
echo "🌐 Access Methods:"
echo "   - NodePort: minikube service frontend-nodeport -n app-stack --url"
echo "   - Ingress: kubectl get ingress -n app-stack"
echo ""
echo "🔍 Pod Status:"
kubectl get pods -n app-stack -o wide