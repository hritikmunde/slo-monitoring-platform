#!/bin/bash

echo "🛑 Shutting down SLO Monitoring Platform"

# Stop any port-forwards (this won't work perfectly, but helps)
echo "⚠️  Please manually stop any port-forward processes (Ctrl+C)"
sleep 2

# Delete kind cluster
echo "🗑️  Deleting kind cluster..."
if kind get clusters 2>/dev/null | grep -q "slo-demo"; then
    kind delete cluster --name slo-demo
    echo "✅ Cluster deleted"
else
    echo "ℹ️  No cluster found (already deleted)"
fi

# Verify cleanup
echo ""
echo "🔍 Verifying cleanup..."
echo "Remaining kind clusters:"
kind get clusters 2>/dev/null || echo "  None"

echo ""
echo "✅ Shutdown complete!"
echo ""
echo "💡 To restart tomorrow, run: ./scripts/setup.sh"