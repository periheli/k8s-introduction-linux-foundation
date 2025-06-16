kubectl -n kube-system describe pod kube-apiserver-minikube | grep -i admission
kubectl run admitted --image=nginx --image-pull-policy=IfNotPresent
kubectl get pod admitted -o yaml | grep -i imagepull
# backup kube-apiserver.yaml
sudo cp /etc/kubernetes/manifests/kube-apiserver.yaml /kube-apiserver-yaml-backup
sudo vi /etc/kubernetes/manifests/kube-apiserver.yaml
# add AlwaysPullImages to the end of --enable-admission-plugins
kubectl run mutated --image=nginx --image-pull-policy=IfNotPresent
kubectl get pod mutated -o yaml | grep -i imagepull
# the `mutated` pod `imagepull` policy is modified but the `admitted` pod deployed prior is not