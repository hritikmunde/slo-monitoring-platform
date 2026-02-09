#!/bin/bash
set -e

echo "🚀 Setting up SLO Monitoring Platform - Day 1"

# Check if the cluster already exists and delete it if it does
if kind get clusters | grep -q "slo-demo"; then
    echo "⚠️  Cluster 'slo-demo' already exists. Deleting..."
    kind delete cluster --name slo-demo
fi

# Create a new kind cluster
echo "🔧 Creating kind cluster 'slo-demo'..."
kind create cluster --name slo-demo --config kind-config.yaml

# Build docker images for the API
echo "📦 Building Docker images for API service..."
docker build -t api-service:v2 -f apps/api/Dockerfile .

# Load image into kind
kind load docker-image api-service:v2 --name slo-demo

# Deploy kubernetes
echo "📂 Deploying Kubernetes manifests..."
kubectl apply -f kubernetes/api-deployment.yaml

# Wait for deployment
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=api --timeout=120s

echo "✅ Setup complete! The API service is running in the 'slo-demo' cluster."
echo ""
echo "🔍 Verify with:"
echo "  kubectl get pods"
echo "  kubectl port-forward svc/api-service 8080:80"
echo "  curl http://localhost:8080/health"