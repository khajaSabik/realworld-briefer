#!/bin/bash

echo "🧹 Cleaning up RealWorld Application..."

kubectl delete -f ingress.yaml
kubectl delete -f frontend-nodeport.yaml
kubectl delete -f frontend-deployment.yaml
kubectl delete -f backend-deployment.yaml
kubectl delete -f db-deployment.yaml
kubectl delete -f db-pvc.yaml
kubectl delete -f configmap-frontend.yaml
kubectl delete -f configmap-backend.yaml
kubectl delete -f secrets.yaml
kubectl delete -f namespace.yaml

echo "✅ Cleanup completed!"