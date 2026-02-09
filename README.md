# SLO Monitoring Platform

Building an SLO-based monitoring system using Sloth, Prometheus, and Grafana on Kubernetes.

## Day 1: Foundation ✅

Built the foundation:
- Kind cluster (3 nodes)
- Sample API microservice with Prometheus metrics
- Automated setup script

### What's Running

- **API Service**: Flask app with `/health`, `/metrics`, `/api` endpoints
- **Replicas**: 2 pods for high availability
- **Metrics**: Exports request count and latency to Prometheus format

### Setup
```bash
./scripts/setup.sh
```

### Test
```bash
kubectl port-forward svc/api-service 8080:80
curl http://localhost:8080/health
```

## Coming Next

- Day 2: Prometheus installation and metrics collection