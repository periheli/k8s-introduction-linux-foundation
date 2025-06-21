kubectl describe pod web-dash-xxx
kubectl get pods -o wide
kubectl get pods -L k8s-app,label2
kubectl get pods -l k8s-app=web-dash
# Deploy imperatively with command
kubectl create deployment webserver \
--image=nginx:alpine --replicas=3 --port=80 \
--dry-run=client -o yaml > def-manifest/webserver-cmd.yaml
kubectl apply -f def-manifest/webserver-cmd.yaml
# Directly create a deployment 
# without creating the YAML definition manifest
kubectl create deployment webserver \
--image=nginx:alpine --replicas=3 --port=80
# Service creation
kubectl expose deployment webserver --name=web-service --type=NodePort
kubectl get services
kubectl describe service web-service
kubectl get po -l app=webserver -o wide
kubectl get ep web-service
kubectl get po,ep -l app=webserver -o wide
kubectl get all -l app=webserver
# Access the service
minikube service web-service
kubectl port-forward service/web-service 8080:80