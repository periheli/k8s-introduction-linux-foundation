kubectl create configmap my-config \
--from-literal=key1=value1 \
--from-literal=key2=value2
kubectl get configmaps my-config -o yaml

kubectl create -f def-manifest/customer-configmap.yaml
kubectl describe cm customer

kubectl create configmap permission-config \
--from-file=def-manifest/permission-reset.properties

kubectl create configmap green-web-cm \
--from-file=def-manifest/green-web/index.html
kubectl get cm green-web-cm -o yaml
kubectl apply -f def-manifest/green-web/green-web-with-cm.yaml
kubectl expose deployment green-web --type=NodePort
minikube service green-web --url
# curl -s http://127.0.0.1:45189/ | head -n 5
(minikube service green-web --url &) | \
xargs -I {} bash -c 'echo "URL: {}" >&2 && curl -s {}/' | \
head -n 5