#!/bin/bash
set -e

echo "🚀 Setting up SLO Monitoring Platform - Day 2"
echo ""

# ============================================
# 1. CREATE KIND CLUSTER
# ============================================
if kind get clusters 2>/dev/null | grep -q "slo-demo"; then
    echo "⚠️  Cluster 'slo-demo' already exists. Deleting..."
    kind delete cluster --name slo-demo
fi

echo "📦 Creating kind cluster..."
kind create cluster --name slo-demo --config kind-config.yaml

# ============================================
# 2. BUILD AND LOAD API SERVICE
# ============================================
echo ""
echo "🐳 Building API service image..."
docker build -t api-service:v3 apps/api/

echo "📥 Loading image into kind cluster..."
kind load docker-image api-service:v3 --name slo-demo

# ============================================
# 3. DEPLOY API SERVICE
# ============================================
echo ""
echo "☸️  Deploying API service..."
kubectl apply -f kubernetes/api-deployment.yaml

echo "⏳ Waiting for API pods to be ready..."
kubectl wait --for=condition=ready pod -l app=api --timeout=120s

# ============================================
# 4. INSTALL PROMETHEUS STACK
# ============================================
echo ""
echo "📊 Installing Prometheus stack..."

# Add Helm repo (if not already added)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update

# Install Prometheus
if helm list -n monitoring 2>/dev/null | grep -q prometheus; then
    echo "⚠️  Prometheus already installed, skipping..."
else
    kubectl create namespace monitoring 2>/dev/null || true
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --wait \
        --timeout 5m
    echo "✅ Prometheus installed"
fi

# ============================================
# 5. DEPLOY SERVICEMONITOR
# ============================================
echo ""
echo "🔍 Deploying ServiceMonitor..."
kubectl apply -f kubernetes/monitoring/api-servicemonitor.yaml

echo "⏳ Waiting for ServiceMonitor to be created..."
sleep 5

# ============================================
# 6. VERIFICATION
# ============================================
echo ""
echo "✅ Setup complete!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 VERIFICATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🔹 API Pods:"
kubectl get pods -l app=api

echo ""
echo "🔹 Prometheus Pods:"
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus

echo ""
echo "🔹 ServiceMonitor:"
kubectl get servicemonitor -n monitoring

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Test your API:"
echo "  kubectl port-forward svc/api-service 8080:80"
echo "  curl http://localhost:8080/health"
echo ""
echo "Access Prometheus UI:"
echo "  kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
echo "  Open: http://localhost:9090"
echo ""
echo "Access Grafana UI (for Day 3):"
echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "  Open: http://localhost:3000"
echo "  Username: admin"
echo "  Password: prom-operator"
echo ""