# Utilisation

La VM de base à utilisier est une VM CentOS 7, avec une installation Docker.

Creéez d'abord une paire de clés privée/publique dans votre VM, pour votre utilisateur:
* En exécutant l'instruction `ssh-keygen -t rsa -b 2048`
* Puis, pour répondez à toutes les questions, en pressant la touche entrée
* Pour vérification, exécutez la commande `ls -all $HOME/.ssh/`, et vous devriez constater que deux fichiers ont été générés, `id_rsa`, et `id_rsa.pub`, respectivement clé privée et publique de la paire que vous venez de générer.

Cela fait, vous devez ajoutez la clé publique `$HOME/.ssh/id_rsa.pub`, à l'ensemble des clés SSH de votre utilisateur gitlab/github:
* Affichez le contenu de votre clé publique avec la commande `cat $HOME/.ssh/id_rsa.pub`
* Copiez collez-le dans le formulaire gitlab/github approprié, [cf. la doc des plateformes respectives](https://help.github.com/articles/)

Ensuite, il faut configurer notre meilleur ami Git : 
```
git config --global user.email "jean.baptiste.lasselle.it@gmail.com"
git config --global user.name "Jean-Baptiste-Lasselle"
# Enfin, depuis Git 2.0 :
git config --global push.default matching
```

Avant d'entrer en cuisine, configurez le package manager de votre VM pour les proxy HTTP et HTTPS de l'infrastructure (chez vous, dans un entreprise):

### CentOS 7
``` 
# - pour configurer le proxy pour le package manager CentOS 7:
echo "proxy=http://nom-domaine-ou-ip-de-votre-srv-proxy:no_port">> /etc/yum.conf
```
### Ubuntu / Debian
``` 
# - Pour configurer le proxy pour le package manager CentOS 7:
echo "Acquire::http::proxy \"http://nom-domaine-ou-ip-de-votre-srv-proxy:no_port/\";" >> /etc/apt/apt.conf
echo "Acquire::https::proxy \"http://nom-domaine-ou-ip-de-votre-srv-proxy:no_port/\";" >> /etc/apt/apt.conf

```

Pour terminer, Kubernetes, tôt ou tard, téléchargera des images Docker, d'un registry Docker. Et il els stockera dans un des sous répertoires de [/var].
Il vous faut donc:
* Vous assurer qu'un espace libre de plus de 30 Go (30 Go vous avez de quoi télécharger un certain nombre d'images déjà) est disponible sous `/var`. L'instruction `df -Th /var` vosu permettra de procéder à cette vérification.
* recourir à la technique qui vous sied, afin d'avoir un espace de 30Go libre sous `/var`
* Imaginos que vous utilisiez LVM, pour la provision des disques durs de vos VMs. Par exemple, si vous avez créé un volume logique `mon-vol-logiqu1` dans un groupe de volumes `grp-vol-un`, et que `/dev/grp-volumes-lvm-un/mon-vol-logiqu1` est monté sur `/var`, alors:
```
sudo lvextend -rn /dev/grp-volumes-lvm-un/mon-vol-logiqu1 -L 37G
``` 
Ce qui étendra à la capacité de `/var` de sa taille initiale, à une taille de 37 giga-octets. 

Vous êtes maintenant prêt à entrer en cuisine, et exécuter la présente recette:

```
# Enfin, pour exécuter cette recette, exécutez les commandes:
export http_proxy=http://nom-domaine-ou-ip-de-votre-srv-proxy:no_port
export https_proxy=http://nom-domaine-ou-ip-de-votre-srv-proxy:no_port

# - 
# - 
export MAISON_OPS=$(pwd)/provision-test-k8s 
rm -rf $MAISON_OPS 
mkdir -p $MAISON_OPS 
cd $MAISON_OPS 
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa" && git clone "git@github.com:Jean-Baptiste-Lasselle/provision-k8s-bis.git" . 
sudo chmod +X ./operations.sh 
sudo ./operations.sh
```
Ou en une seule ligne:
```
# si vous avez un proxy dans votre infra:
# export http_proxy=http://nom-domaine-ou-ip-de-votre-srv-proxy:no_port
# export https_proxy=http://nom-domaine-ou-ip-de-votre-srv-proxy:no_port
export MAISON_OPS=$(pwd)/provision-test-k8s  && rm -rf $MAISON_OPS  && mkdir -p $MAISON_OPS  && cd $MAISON_OPS  && export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_rsa" && git clone "git@github.com:Jean-Baptiste-Lasselle/provision-k8s-bis.git" .  && sudo chmod +x ./operations.sh  && sudo ./operations.sh
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

[votreutilisateur@pc-65 provision-test-k8s]$ # notez que "pc-65" est un nom d'hôte attribué par le routeur de mon F.A.I. (ma "box")  
[votreutilisateur@pc-65 provision-test-k8s]$ 

```

# Principe

Cette recette réalise la provision d'un cluster Kubernetes, à l'aide de 6 machines virutelles, comme proposé dans l'une des documentations officielles Kubernetes.
Mettre en oeuvre, et dans un second temps, exploiter, un cluster Kubernetes, dans le cadre d'un cycle de vie / de développement / d'exploitation, d'un logiciel.

En son premier état, la recette a été testée avec un hôte Docker CentOS 7, la machine ayant plein accès à internet, derrière un routeur FAI avec masquerade.
Dans cette machine, ont été testés l'installation des 3 composants principaux Kubernetes:
* `kubectl`
* `kubeadm`
* `kubelet`


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
 
Au cours des tests j'ai collecté un mesage d'erreur, concernant la compatibilité de la version de Kubernetes, avec la version de Docker. 
Le message était le suivant:

```
[init] using Kubernetes version: v1.11.0
[preflight] running pre-flight checks
I0618 02:45:08.780182   23143 kernel_validator.go:81] Validating kernel version
I0618 02:45:08.780292   23143 kernel_validator.go:96] Validating kernel config
        [WARNING SystemVerification]: docker version is greater than the most recently validated version. Docker version: 18.05.0-ce. Max validated version: 17.03
[preflight] Some fatal errors occurred:
        [ERROR Swap]: running with swap on is not supported. Please disable swap
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
[jbl@pc-65 1]$
```

# ANNEXE: créer un personal access token sur Github, pour utiliser l'API...

cf. https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/


# TROUBLESHOOTING


Quelques commandes que j'ai testées avec succès:

```
sudo kubectl --kubeconfig=$HOME/.kube/config get events --watch
```


Illustration avec ma première réussite de passage au statut "NodeReady"...:

![Première réussite - Cluster 3 noeuds statut 'NodeReady'](https://github.com/Jean-Baptiste-Lasselle/provision-k8s-bis/raw/master/images/cluster-k8s-3-VMs.png)

En témoigne `kubectl`:

![Première réussite - passage au statut 'NodeReady'](https://github.com/Jean-Baptiste-Lasselle/provision-k8s-bis/raw/master/images/premiere-reussite-k8s-avec-flannel-pr-passer-statut-node-ready.png)


```
sudo kubectl get services -n kube-system
```
## Point de reprise

Je n'arrive pas encore à atteindrele dashboard Kubernetes.

D'après [cette docuementation du dashboard](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user) : 

* Pour la création des users du dashboard Kubernetes : 

```
[jbl@pc-65 provision-test-k8s]$ pwd
/home/jbl/provision-test-k8s/provision-test-k8s
[jbl@pc-65 provision-test-k8s]$ export MAISON=`pwd`
[jbl@pc-65 provision-test-k8s]$ sudo kubectl apply -f $MAISON/add-ons/create-service-account.yml
serviceaccount/admin-user created
[jbl@pc-65 provision-test-k8s]$ sudo kubectl apply -f $MAISON/add-ons/create-cluster-role-binding.yml
clusterrolebinding.rbac.authorization.k8s.io/admin-user created
[jbl@pc-65 provision-test-k8s]$

```

* Puis on peut retrouver le token d'authentification au Dashboard Kubernetes en exécutant : 

```
sudo kubectl -n kube-system describe secret $(sudo kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

Bien, ensuite, il faut bien comprendre le principe de ce dashboard: c'est un dashboard d'administration, si bien qu'il n'est censé être servi, que localement.
En clair, si vous voulez accéder au dashboard kubernetes, depuis une machien quelconque, différente d'une machien serveur maître, il va falloir que vous 
trouviez un moyen de "faire croire que le dashboard est local", à votre pile tcp / ip OS. 
La solution est d'utiliser un prixy, qui est fournit par `kubectl`.

Disons que le maître du cluster soit un serveur, et que vous souhaitiez accéeder au dashboard kubernetes depusi votre machine.
Alors, il val falloir:
* Installer [chocolatey](https://chocolatey.org/install) sur votre machine windows. Pour cela, vous ouvrirez une consile MS-DOS (faîtes la traduction en Powershell, qui est [donnée dans la doc kubernetes](https://kubernetes.io/docs/tasks/tools/install-kubectl/) )
* Installer `kubectl` sur votre machine Windows avec chocolatey (merci choco!), en exécutant:
```
choco install kubernetes-cli
```
* Configurer `kubectl`, en :
  * Sur le maître, copiez le contenu du fichier `/root/.kube/config` (ou `$HOME/.kube/config`),
  * Sur votre poste Windows, créez un fichier "C:\repertoire\quel\conque\config", et collez le contenu copié précédemment, dans ce fichier (attention au format de fichiers windows/unix, le formt doit être unix)
* exécutez :
```
kubectl proxy --port=1536
```
Et enfin, accéder à l'url suivante:
```
http://127.0.0.1:1536/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default
```
On arrive sur la page suivante, dans lequelle le dashboard nous demande de nosu authentifier, en nosu rpoposant deux méthodes. 
On utilisera la méhode du token, et nous renseignerons la valeur que nous avons généré avec `sudo kubectl apply -f $MAISON/add-ons/create-service-account.yml`

![Dashboard Enfin](https://github.com/Jean-Baptiste-Lasselle/provision-k8s-bis/raw/master/images/reussite-k8s-dashboard-classique-1-web-ui-et-URL.png)

Ce qui nous donnera, après authentification:

![Dashboard je suis auth.](https://github.com/Jean-Baptiste-Lasselle/provision-k8s-bis/raw/master/images/reussite-k8s-dashboard-classique-3-LOGIN-REUSSIT-AVEC-TOKEN.png)

Ci dessous, l'écran MS-DOS dans lequel j'ai exécuté le proxy kubectl sur ma machien windows est visible:

![Kubectl Proxy / Dashboard](https://github.com/Jean-Baptiste-Lasselle/provision-k8s-bis/raw/master/images/reussite-k8s-dashboard-classique-2-CHOCOLATEY-KUBECTL-PROXY-MSDOS.png)

Et voilà la liste des 3 nodes créés:

![Kubectl Proxy / Dashboard](https://github.com/Jean-Baptiste-Lasselle/provision-k8s-bis/raw/master/images/reussite-k8s-dashboard-classique-4-LISTE-DES-NODES-OUII.png)

### TODO: faire l'évolution dans le scripts, pour automatiser cela.

### Sur les pod network

 impression écran montrant que j'ai: [1. créé le maitre et initialise le pod network avant de crééer l'esclave. Puis j'ai créé un premier esclave, et les 2 passent dans l'étant "Ready"]:
 
![Kubectl Proxy / Dashboard](https://github.com/Jean-Baptiste-Lasselle/provision-k8s-bis/raw/master/images/esclave-ajoute-apres-deploiement-pod-network-devient-ready.png)