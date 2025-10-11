#!/bin/bash

echo "🚀 Deploying RealWorld Application to Kubernetes..."

echo "1. Creating namespace..."
kubectl apply -f namespace.yaml

echo "2. Creating secrets..."
kubectl apply -f secrets.yaml

echo "3. Creating config maps..."
kubectl apply -f configmap-backend.yaml
kubectl apply -f configmap-frontend.yaml

echo "4. Setting up database persistence..."
kubectl apply -f db-pvc.yaml

echo "5. Deploying PostgreSQL database..."
kubectl apply -f db-deployment.yaml

echo "6. Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n app-stack --timeout=120s

echo "7. Deploying Backend API..."
kubectl apply -f backend-deployment.yaml

echo "8. Deploying Frontend..."
kubectl apply -f frontend-deployment.yaml

echo "9. Setting up Ingress..."
kubectl apply -f ingress.yaml

echo "10. Setting up NodePort (alternative access)..."
kubectl apply -f frontend-nodeport.yaml

echo "✅ Deployment completed!"

echo ""
echo "📊 Checking deployment status..."
kubectl get all -n app-stack

echo ""
echo "🌐 Access Methods:"
echo "   - Ingress URL: Check with 'kubectl get ingress -n app-stack'"
echo "   - NodePort: minikube service frontend-nodeport -n app-stack --url"
echo ""
echo "🔍 To check logs:"
echo "   kubectl logs -f deployment/backend -n app-stack"
echo "   kubectl logs -f deployment/frontend -n app-stack"