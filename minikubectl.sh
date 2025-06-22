minikube start --driver=docker -n 3
minikube start
minikube profile list
minikube stop


kubectl proxy
minikube dashboard --url


kubectl apply -f pods/nginx-pod.yaml
kubectl apply -f pods/nginx-latest.yaml
kubectl describe pods nginx-latest
kubectl get pods -o wide
kubectl delete pods nginx-latest nginx-pod

kubectl apply -f pods/redis-rs.yaml
kubectl get replicasets
kubectl get rs
kubectl scale rs frontend --replicas=4
kubectl get rs frontend -o yaml
kubectl get rs frontend -o json
kubectl describe rs frontend
kubectl delete rs frontend

kubectl apply -f pods/nginx-deploy.yaml --record
kubectl get deploy -o wide
kubectl scale deploy nginx-deployment --replicas=4
kubectl get deploy nginx-deployment -o yaml
kubectl describe deploy nginx-deployment
kubectl rollout status deploy nginx-deployment
kubectl rollout history deploy nginx-deployment
kubectl rollout history deploy nginx-deployment --revision=1

kubectl apply -f pods/nginx-deploy.yaml 
kubectl set image deployment nginx-deployment nginx=nginx:1.27.5
kubectl annotate deployment nginx-deployment kubernetes.io/change-cause="image updated to 1.27.5" --overwrite=true

kubectl rollout undo deploy nginx-deployment --to-revision=1
kubectl get all -l app=nginx-deployment -o wide
kubectl get deploy,rs,po -l app=nginx-deployment
kubectl delete deploy nginx-deployment


kubectl apply -f pods/fluentd-ds.yaml
kubectl get ds -o wide
kubectl get ds -A
kubectl rollout status ds fluentd-agent
kubectl rollout history ds fluentd-agent
kubectl set image ds fluentd-agent fluentd=quay.io/fluentd_elasticsearch/fluentd:v4.6.2
kubectl annotate ds fluentd-agent kubernetes.io/change-cause="image updated to 4.6.2" --overwrite=true
kubectl get all -l k8s-app=fluentd-agent -o wide

# Check image availability
kubectl run hello-world -ti --rm --image=registry.k8s.io/busybox:latest \
--restart=Never -- date Fri Feb 31 07:07:07 UTC 2023

# Preload image into Minikube
docker pull alpine
minikube image load alpine:latest
minikube cache list
