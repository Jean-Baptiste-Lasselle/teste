# Utilisation

La VM de base à utiliser est une VM CentOS 7, avec une installation Docker.

Creéez d'abord une paire de clés privée/publique dans votre VM, pour votre utilisateur:
* En exécutant l'instruction `ssh-keygen -t rsa -b 2048`
* Puis, répondez à toutes les questions en pressant la touche entrée
* Pour vérification, exécutez la commande `ls -all $HOME/.ssh/`, et vous devriez constater que deux fichiers ont été générés, `id_rsa`, et `id_rsa.pub`, respectivement clé privée et publique de la paire que vous venez de générer.

Cela fait, vous devez ajoutez la clé publique `$HOME/.ssh/id_rsa.pub`, à l'ensemble des clés SSH de votre utilisateur gitlab/github:
* Affichez la valeur de votre clé publique avec la commande `cat $HOME/.ssh/id_rsa.pub`
* Copiez collez cette valeur dans le formulaire gitlab/github destiné à enregistrer une nouvelle clé publique pour l'authentification SSH. Cf. la doc des plateformes respectives sur le sujet, comme [celle de github](https://help.github.com/articles/)

```
# Enfin, pour exécuter cette recette, exécutez les commandes:
export MAISON_OPS=$(pwd)/provision-test-k8s 
rm -rf $MAISON_OPS 
mkdir -p $MAISON_OPS 
cd $MAISON_OPS 
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa" && git clone "git@github.com:Jean-Baptiste-Lasselle/provision-k8s" . 
sudo chmod +X ./operations.sh 
sudo ./operations.sh
```
Ou en une seule ligne:
```
export MAISON_OPS=$(pwd)/provision-test-k8s  && rm -rf $MAISON_OPS  && mkdir -p $MAISON_OPS  && cd $MAISON_OPS  && export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa" && git clone "git@github.com:Jean-Baptiste-Lasselle/provision-k8s" .  && sudo chmod +x ./operations.sh  && sudo ./operations.sh
```

Lorsque l'installation s'est terminée avec succès, vous devriez avoir à l'écran un affichage de la forme:

```
[bootstraptoken] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstraptoken] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstraptoken] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstraptoken] creating the "cluster-info" ConfigMap in the "kube-public" namespace
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 192.168.1.12:6443 --token x3hh5i.rlmu5czjisdb3boe --discovery-token-ca-cert-hash sha256:480b38a24ad9c726d27485a4146dea60fecff0ed658bd81dd273d2bae4a7f1aa

[votreutilisateur@pc-65 provision-test-k8s]$ # notez que "pc-65" est un nom d'hôte attribué par le (serveur dhcp/dns situé dans le) routeur de mon F.A.I. (ma "box") 
[votreutilisateur@pc-65 provision-test-k8s]$ 

```

premier test qui ait marché pour faire un worker:

```
# Et donc il faudra traiter la question du certificat ssl, pour le use case où l'on remplace un vieux serveur par un neuf
sudo kubeadm join 192.168.1.12:6443 --token 1pezx1.zmq981vsje7ig46a  --discovery-token-unsafe-skip-ca-verification 
``` 
Pour vérifier, on a besoin d'utiliser kubectl. Pour uitiliser kubetctl, il faut une version correcte de sa config.
Lorsque l'on installe la premier maître, la sortie standard finit par nous donner 3 instructions à exécuter pour utiliser une config valide qui a été générée au cours du processus d'installation:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
Mais atention, comme nous allons utiliser `sudo`, afin d'excécuter kubectl, on doit appliquer cette configuration pour le user root:

```
sudo -i
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```
Après cela, exécutez `sudo kubectl get nodes`, vous devriez avoir un affichage mentionnant vos deux machines:

```
Last login: Sat Jun 30 04:36:25 2018
[jbl@pc-65 ~]$ sudo kubectl get nodes
[sudo] Mot de passe de jbl : 
NAME         STATUS     ROLES     AGE       VERSION
pc-27.home   NotReady   <none>    20m       v1.11.0
pc-65.home   NotReady   master    1h        v1.11.0
[jbl@pc-65 ~]$

```

et on obtient le même résultat, avec la même configuration de kubectl, côté worker (copier le fichier de config qui a été généré sur le maître, vers le worker)

```
[jbl@pc-27 provision-test-k8s]$ ip addr|grep 168
    inet 192.168.1.16/24 brd 192.168.1.255 scope global dynamic enp0s3
    inet 192.168.1.17/24 brd 192.168.1.255 scope global dynamic enp0s8
[jbl@pc-27 provision-test-k8s]$ sudo mkdir -p /root/.kube
[sudo] Mot de passe de jbl : 
[jbl@pc-27 provision-test-k8s]$ sudo cp /home/jbl/.kube/config /root/.kube/config
[jbl@pc-27 provision-test-k8s]$ sudo kubectl get nodes
NAME         STATUS     ROLES     AGE       VERSION
pc-27.home   NotReady   <none>    32m       v1.11.0
pc-65.home   NotReady   master    1h        v1.11.0
[jbl@pc-27 provision-test-k8s]$ echo $HOSTNAME
pc-27.home
[jbl@pc-27 provision-test-k8s]$

```

### Bootstrap token

L'instruction ci-dessous fait usage d'un "token" d'authentification de la machine au maître du cluster:

```
export ADRESSE_IP_MASTER1_API_INTERFACE=192.168.1.12
# export NO_PORT_IP_MASTER1_API_INTERFACE=6443
export NO_PORT_IP_MASTER1_API_INTERFACE=5543
sudo kubeadm join £ADRESSE_IP_MASTER1_API_INTERFACE:£NO_PORT_IP_MASTER1_API_INTERFACE --token 1pezx1.zmq981vsje7ig46a  --discovery-token-unsafe-skip-ca-verification 
```

Pour générer un nouveau token, utilisable par une machine, pour rejoindre un cluster Kubernetes, il faut, au sein d'un des maîtres du cluster, exécuter la commande:

```
sudo kubeadm token create
# Ce qui affichera dans la sortie standard, une valeur que vous pouvez utiliser depuis une machine candidate à rejoindre le cluster
```

D'autre part, 'adresse IP et le numéro de port mentionnés dans la commande:
```
sudo kubeadm join £ADRESSE_IP_MASTER1_API_INTERFACE:£NO_PORT_IP_MASTER1_API_INTERFACE --token 1pezx1.zmq981vsje7ig46a  --discovery-token-unsafe-skip-ca-verification 
```

Sont les adresses ip et numéro de port utilisé par l'API kubernetes sur l'un des maîtres du cluster.

Lorsque l'on initialise le premier maître du cluster, on peut spécifier cette adresse IP et ce numéro de port, à l'aide de la syntaxe suivante:
```
# - ENV.

# Dixit la doc Kubernetes officielle: "The IP address the API Server will advertise it's listening on. Specify '0.0.0.0' to use the address of the default network interface."
export ADRESSE_IP_MASTER1_API_INTERFACE=192.168.1.12

# Dixit la doc Kubernetes officielle: "Port for the API Server to bind to.Default: 6443"
export NO_PORT_IP_MASTER1_API_INTERFACE=5543

# - Master 1 Init.
kubeadm init --apiserver-advertise-address $ADRESSE_IP_MASTER1_API_INTERFACE --apiserver-bind-port $NO_PORT_IP_MASTER1_API_INTERFACE     
```

# TODOs

Il est possible d'utiliser les arguments de `kubeadm init <args>` pour spécifier l'adresse IP de binding qui est utilisée par l'instruction `kubeadm join ...`.
Voir https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/

La recette doit être modifiée, pour que:
* Sur le(s) maître(s) du cluster, `master1-k8s`, ce soit `test5-creer-cluster-k8s-init-master.sh` qui est excécuté.
* Sur les 2 "workers", `worker1-k8s` et `worker2-k8s`, ce soit `test5-creer-cluster-k8s-init-worker.sh` qui est excécuté.

Extrait de `./test5-creer-cluster-k8s-init-worker.sh` (la recette doi savoir faire passer une valeur d'une VM à l'autre):

```
clear
# Le fichier [./fichier-contenant-cmd-join-master1.log] est
# censé avoir été récupéré du premier maître du cluster et
# il contient la sortie standard de la commande :
#     sudo kubeadm init >> ./fichier-contenant-cmd-join-master1.log
# qui a été exécutée sur le premier maître du cluster.
# - 
# La sortie standard de la commande [sudo kubeadm init] contient une commande de la forme:
# 
# 
#   #
#   You can now join any number of machines by running the following on each node
#   as root:
# 
#        kubeadm join 192.168.1.12:6443 --token x3hh5i.rlmu5czjisdb3boe --discovery-token-ca-cert-hash sha256:480b38a24ad9c726d27485a4146dea60fecff0ed658bd81dd273d2bae4a7f1aa
# 
# 
# - 
# Et cette commande doit être exécutée

export CMD_JOIN_MASTER=$(cat ./fichier-contenant-cmd-join-master1.log|grep kubeadm|grep join)
```

# Principe

Cette recette réalise la provision d'un cluster Kubernetes, à l'aide de 6 machines virutelles, comme proposé dans l'une des documentations officielles Kubernetes.
Mettre en oeuvre, et dans un second temps, exploiter, un cluster Kubernetes, dans le cadre d'un cycle de vie / de développement / d'exploitation, d'un logiciel.



En son premier état, la recette a été testée avec un hôte Docker CentOS 7, la machine ayant plein accès à internet, derrière un routeur FAI avec masquerade.
Dans cette machine, ont été testés l'installation des 3 composants principaux Kubernetes:
* `kubectl`
* `kubeadm`
* `kubelet`

Au cours des tests j'ai collecté un message d'avertissement, concernant la compatibilité de la version de Kubernetes, avec la version de Docker. 
Le message était le suivant:

```
[init] using Kubernetes version: v1.11.0
[preflight] running pre-flight checks
I0618 02:45:08.780182   23143 kernel_validator.go:81] Validating kernel version
I0618 02:45:08.780292   23143 kernel_validator.go:96] Validating kernel config
        [WARNING SystemVerification]: docker version is greater than the most recently validated version. Docker version: 18.05.0-ce. Max validated version: 17.03

[jbl@pc-65 1]$
```

# ANNEXE: trouvé

Sur le master 1, on doit terminer par:
```
# Et il NE FAUT PAS exécuter cette instrcution sur les workers
sudo kubeadm init
```
Et sur les workers, j'exécute la commande de la forme: 
```
# notez les référence à l'adresse IP de la VM master 1, au numéro de port IP spécifique Kubernetes, 6443, et
# aux credentials qui ont été générés sur le "master1" , par la commande [sudo kubeadm init]
sudo kubeadm join 192.168.1.12:6443 --token cq9c0x.vjq094vfem8mse09 --discovery-token-ca-cert-hash sha256:f04c16d04c5e0f29806db0e9dba0f0d06d22ad63324e7de1d9c5d1de56c240af
# kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>
```
