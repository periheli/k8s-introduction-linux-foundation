kubectl apply -f def-manifest/app-blue-shared-vol.yaml
kubectl expose deployment blue-app --type=NodePort
minikube service list
minikube service blue-app