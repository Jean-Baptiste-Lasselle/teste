# - On installe la configuration pour 2 utilisateurs:
#     "UTILISATEUR_DE_DEPART"
# et
#     "root" 
export UTILISATEUR_DE_DEPART=$USER

# - CONFIGURATION KUBECTL pour "root"  / ça pose porblème, je reste en root, et je ne veux pas toucher aux ugo pour l'instant. Donc je ne le fais pas.
# sudo -s
# - on fait cela en tant que "root"
# rm -rf $HOME/.kube
# mkdir -p $HOME/.kube
# cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# chown $(id -u):$(id -g) $HOME/.kube/config

# - CONFIGURATION KUBECTL pour "$UTILISATEUR_DE_DEPART"
# - on redonne la main à l' $UTILISATEUR_DE_DEPART
# su $UTILISATEUR_DE_DEPART
cd $HOME
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sudo mkdir -p /root/.kube
sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
sudo chown root:root /root/.kube/config
# - Et maintenant, l'utilisateur $UTILISATEUR_DE_DEPART peut exécuter:
# sudo kubectl get nodes
#   # ou (pas encore) :
# kubectl get nodes
rm -f ./test-kubectl-get-nodes.resultat
echo "# --------------------------------------------------------------------------------------------------- "  >> ./test-kubectl-get-nodes.resultat
echo "# si le test est concluant, vous devriez voir apparaître ci-dessous, une sortie standard de la forme:"  >> ./test-kubectl-get-nodes.resultat
echo "# --------------------------------------------------------------------------------------------------- "  >> ./test-kubectl-get-nodes.resultat
echo "# NAME           STATUS     ROLES     AGE       VERSION"  >> ./test-kubectl-get-nodes.resultat
echo "# maitre1-jbl    NotReady   master    54m       v1.11.0"  >> ./test-kubectl-get-nodes.resultat
echo "# server180627   NotReady   <none>    51m       v1.11.0"  >> ./test-kubectl-get-nodes.resultat
echo "# "  >> ./test-kubectl-get-nodes.resultat
echo "# --------------------------------------------------------------------------------------------------- "  >> ./test-kubectl-get-nodes.resultat
echo "# --------------------------------------------------------------------------------------------------- "  >> ./test-kubectl-get-nodes.resultat
sudo kubectl get nodes >> ./test-kubectl-get-nodes.resultat 2>&1
echo "# --------------------------------------------------------------------------------------------------- "  >> ./test-kubectl-get-nodes.resultat
echo "# 			FIN TEST CONFIG - KUBECTL"  >> ./test-kubectl-get-nodes.resultat
echo "# si le test est concluant, vous devriez voir apparaître ci-dessous, une sortie standard de la forme:"  >> ./test-kubectl-get-nodes.resultat
echo "# --------------------------------------------------------------------------------------------------- "  >> ./test-kubectl-get-nodes.resultat