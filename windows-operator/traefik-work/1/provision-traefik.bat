
REM -- ENV. ---

set KUBECONFIG=..\..\config
kubectl apply -f .\traefik-rbac.yaml
REM -- cf.  https://raw.githubusercontent.com/containous/traefik/master/examples/k8s/traefik-rbac.yaml

kubectl apply -f .\traefik-k8s-deployment.yaml
REM -- cf.  https://github.com/containous/traefik/blob/master/examples/k8s/traefik-deployment.yaml

echo " --------------------------------------------------- "
echo " Documentation:"
echo " --------------------------------------------------- "
echo "  https://docs.traefik.io/user-guide/kubernetes/ "
echo " --------------------------------------------------- "