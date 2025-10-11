#!/bin/bash

echo "🚀 Deploying Complete Application Stack..."

echo "1. Deploying Backend..."
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

echo "2. Waiting for Backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n app-stack --timeout=120s

echo "3. Deploying Frontend..."
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f frontend-nodeport.yaml

echo "4. Setting up Ingress..."
kubectl apply -f ingress.yaml

echo "⏳ Waiting for all components to stabilize..."
sleep 20

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