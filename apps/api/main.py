from flask import Flask, jsonify
from prometheus_client import Counter, Histogram, generate_latest
import time
import random

app = Flask(__name__)

# Prometheus metrics
http_requests_total = Counter(
    'http_requests_total', 
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

http_request_duration_seconds = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration in seconds',
    ['method', 'endpoint']
)

@app.route('/health')
def health():
    """Health check endpoint for Kubernetes"""
    return jsonify({'status': 'healthy'}), 200

@app.route('/metrics')
def metrics():
    """Prometheus metrics endpoint"""
    return generate_latest()

@app.route('/api')
def api():
    """Main API endpoint we'll monitor for SLOs"""
    start_time = time.time()
    
    # Simulate some work
    time.sleep(random.uniform(0.01, 0.1))
    
    # Record metrics
    duration = time.time() - start_time
    http_request_duration_seconds.labels(method='GET', endpoint='/api').observe(duration)
    http_requests_total.labels(method='GET', endpoint='/api', status='200').inc()
    
    return jsonify({'message': 'success', 'data': 'sample'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)