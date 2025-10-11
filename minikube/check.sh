#!/bin/bash

echo "🔧 Troubleshooting and Re-deploying Application..."

echo "1. Checking PostgreSQL issue..."
kubectl describe pod -l app=postgres -n app-stack

echo "2. Checking Backend init container..."
kubectl describe pod -l app=backend -n app-stack

echo "3. Deleting problematic deployments..."
kubectl delete deployment postgres backend frontend -n app-stack
kubectl delete service postgres-service backend-service frontend-service frontend-nodeport -n app-stack

echo "4. Verifying secrets exist..."
kubectl get secrets -n app-stack

echo "5. Re-deploying with proper order and debugging..."

echo "5.1 Deploying PostgreSQL..."
kubectl apply -f db-deployment.yaml
echo "Waiting for PostgreSQL..."
sleep 10
kubectl get pods -l app=postgres -n app-stack

# Check PostgreSQL logs if still failing
POSTGRES_POD=$(kubectl get pods -l app=postgres -n app-stack -o jsonpath='{.items[0].metadata.name}')
if kubectl get pod $POSTGRES_POD -n app-stack | grep -q "Error"; then
    echo "❌ PostgreSQL failed - checking logs:"
    kubectl logs $POSTGRES_POD -n app-stack
    echo "Check your secrets.yaml and db-deployment.yaml configuration"
    exit 1
fi

kubectl wait --for=condition=ready pod -l app=postgres -n app-stack --timeout=120s

echo "5.2 Deploying Backend..."
kubectl apply -f backend-deployment.yaml
echo "Waiting for Backend..."
sleep 10
kubectl get pods -l app=backend -n app-stack

kubectl wait --for=condition=ready pod -l app=backend -n app-stack --timeout=120s

echo "5.3 Deploying Frontend..."
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f frontend-nodeport.yaml

echo "5.4 Deploying Backend Service..."
kubectl apply -f backend-service.yaml

echo "5.5 Setting up Ingress..."
kubectl apply -f ingress.yaml

echo "⏳ Waiting for all components to be ready..."
sleep 30

echo "✅ Final deployment status:"
kubectl get all -n app-stack

echo ""
echo "🔍 Debugging info:"
echo "PostgreSQL:"
kubectl get pods -l app=postgres -n app-stack
echo "Backend:"
kubectl get pods -l app=backend -n app-stack
echo "Frontend:"
kubectl get pods -l app=frontend -n app-stack

echo ""
echo "📋 If issues persist, check:"
echo "   kubectl describe pod -l app=postgres -n app-stack"
echo "   kubectl logs -l app=postgres -n app-stack"
echo "   kubectl get secrets -n app-stack"