
REM -- ENV. ---

set KUBECONFIG=..\..\config

kubectl --namespace=kube-system get pods 2>&1 | tee -a .\fichier-contenant-resultats-de-tests.provision-k8s

echo " --------------------------------------------------- "
echo " Documentation:"
echo " --------------------------------------------------- "
echo "  https://docs.traefik.io/user-guide/kubernetes/ "
echo " --------------------------------------------------- "