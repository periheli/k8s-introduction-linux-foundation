kubectl create -f svc/fe-app.yaml
kubectl create -f svc/fe-svc.yaml
kubectl expose deploy frontend --name=frontend-svc \
--port=80 --target-port=5000
kubectl create service clusterip frontend \
--tcp=80:5000 --dry-run=client -o yaml \
| sed 's/name: frontend/name: frontend-svc/g' \
| kubectl apply -f -

kubectl get service,endpoints frontend-svc
kubectl get svc,ep frontend-svc
kubectl get svc,ep,po --show-labels

kubectl expose deploy frontend --name=frontend-svc \
--port=80 --target-port=5000 --type=NodePort

kubectl create service nodeport frontend-svc \
--tcp=80:5000 --node-port=32233

kubectl create deployment deploy-hello --image=pbitty/hello-world:latest \
--port=80 --replicas=3
kubectl set image deployment deploy-hello hello-world=pbitty/hello-from:latest
kubectl describe deploy deploy-hello

kubectl expose deploy deploy-hello --type=NodePort

kubectl get deploy,po,svc,ep -l app=deploy-hello --show-labels