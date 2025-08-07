#!/bin/bash

# Check OpenShift namespace storage capacity and recommend database type
set -euo pipefail

NAMESPACE="$1"
MIN_STORAGE_GB="${2:-4}"

echo "Checking storage capacity for namespace: $NAMESPACE"

# Get namespace resource quota for storage
if oc get resourcequota -n "$NAMESPACE" 2>/dev/null | grep -q "storage"; then
    # Get storage quota
    STORAGE_QUOTA=$(oc get resourcequota -n "$NAMESPACE" -o json | jq -r '.items[] | select(.spec.hard["requests.storage"]) | .spec.hard["requests.storage"]' | head -1)
    
    if [ -n "$STORAGE_QUOTA" ] && [ "$STORAGE_QUOTA" != "null" ]; then
        # Convert to GB for comparison
        STORAGE_GB=$(echo "$STORAGE_QUOTA" | sed 's/[^0-9.]//g')
        
        echo "Namespace storage quota: ${STORAGE_QUOTA} (${STORAGE_GB} GB)"
        
        if (( $(echo "$STORAGE_GB < $MIN_STORAGE_GB" | bc -l) )); then
            echo "WARNING: Namespace has ${STORAGE_QUOTA} storage capacity"
            echo "Recommendation: Use single PostgreSQL instance"
            echo "recommended_type=single" >> $GITHUB_OUTPUT
            exit 0
        fi
    fi
fi

echo "Storage capacity check passed - Crunchy deployment suitable"
echo "recommended_type=crunchy" >> $GITHUB_OUTPUT
