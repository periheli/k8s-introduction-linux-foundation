#!/bin/bash
SERVICE_NAME=${1:-airflow}
ENV=${2:-}

# Directories in order of precedence
DIRS=(
    "helm-values/base"
    "helm-values/common" 
    "helm-values/environments/$ENV"
)

VALUES_ARGS=""
for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        for file in $(ls "$dir"/*.yaml 2>/dev/null | sort); do
            VALUES_ARGS="$VALUES_ARGS -f $file"
        done
    fi
done

helm upgrade --install airflow$ENV apache-airflow/airflow \
		--namespace $SERVICE_NAME \
		--create-namespace \
		$VALUES_ARGS \
		--debug