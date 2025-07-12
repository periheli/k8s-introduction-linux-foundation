include ./colors.mk

.ONESHELL:
SHELL = /bin/bash
PYTHON = python3.12
VENV = .venv
BUILD_DIR = dags

# Python Virtual Environment
.PHONY: venv
venv:
	@echo -e "$(COLOR_GREEN)Creating virtual environment...$(END_COLOR)"
	${PYTHON} -m venv ${VENV}
	@echo -e "$(COLOR_GREEN)Activating virtual environment and installing dependencies...$(END_COLOR)"
	source ${VENV}/bin/activate && \
	${PYTHON} -m pip install --default-timeout=1000 --upgrade pip && \
	${PYTHON} -m pip install --default-timeout=1000 -r requirements.txt

.PHONY: style
style:
	@echo -e "$(COLOR_GREEN)Running code style checks...$(END_COLOR)"
	
	source ${VENV}/bin/activate && \
	echo -e "$(COLOR_GREEN)Running black...$(END_COLOR)"
	black ${BUILD_DIR} ; \
	echo -e "$(COLOR_GREEN)Running isort...$(END_COLOR)"
	isort ${BUILD_DIR} ; \
	echo -e "$(COLOR_GREEN)Running flake8...$(END_COLOR)"
	flake8 ${BUILD_DIR}

SERVICE_NAME = airflow


set_defaults:
	@echo "Setting default namespace to ${SERVICE_NAME} ..."
	@kubectl config set-context --current --namespace=${SERVICE_NAME}

install_chart:
	@echo "Installing Helm chart for Airflow ..."
	@helm repo add apache-airflow https://airflow.apache.org
	@helm upgrade --install airflow apache-airflow/airflow \
		--namespace ${SERVICE_NAME} \
		--create-namespace \
		--debug \
		--set useStandardNaming=true

get_config:
	@echo "Fetching Airflow configuration ..."
	@helm show values apache-airflow/airflow > values.yaml
	@echo "Configuration saved to values.yaml"

deploy:
	@echo "Deploying Helm chart for Airflow ..."
	@kubectl apply -f airflow-secrets.yaml --namespace ${SERVICE_NAME}
	@chmod +x deploy.sh
	@./deploy.sh

expose_service:
	@echo "Exposing Airflow service ..."
	@mkdir -p .tmp
	@nohup kubectl port-forward svc/airflow-api-server 8080:8080 > /dev/null 2>&1 & \
	echo $$! > .tmp/port_forward.pid && \
	echo "Airflow webserver will be available at http://127.0.0.1:8080." && \
	echo "Use 'make stop_port_forward' to stop it."

stop_port_forward:
	@echo "Stopping port forwarding for Airflow service ..."
	@if [ -f .tmp/port_forward.pid ]; then \
		PID=$$(cat .tmp/port_forward.pid); \
		kill $$PID && echo "Port forwarding stopped."; \
		rm -f .tmp/port_forward.pid; \
	else \
		echo "No port forwarding process found."; \
	fi

# Debugging and Monitoring
get_pod_logs:
	@echo "Fetching logs from Airflow pods ..."
	@kubectl get pods --namespace ${SERVICE_NAME}
	@read -p "Enter the pod name to fetch logs: " POD_NAME; \
	kubectl logs $$POD_NAME --namespace ${SERVICE_NAME}

get_pod_events:
	@echo "Fetching events for Airflow pods ..."
	@kubectl get pods --namespace ${SERVICE_NAME}
	@read -p "Enter the pod name to fetch events: " POD_NAME; \
	# kubectl describe pod $$POD_NAME --namespace ${SERVICE_NAME}
	kubectl get events --field-selector involvedObject.kind=Pod,involvedObject.name=$$POD_NAME