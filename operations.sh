#!/bin/bash


# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
################                                                ENVIRONNEMENT                                            #####################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

export MAISON=`pwd`
export ADRESSE_IP_K8S_API_SERVER_PAR_DEFAUT=0.0.0.0
export ADRESSE_IP_K8S_API_SERVER=$ADRESSE_IP_K8S_API_SERVER_PAR_DEFAUT
export NO_PORT_IP_K8S_API_SERVER_PAR_DEFAUT=6443
export NO_PORT_IP_K8S_API_SERVER=$NO_PORT_IP_K8S_API_SERVER_PAR_DEFAUT

export VERSION_K8S_PAR_DEFAUT=1.11.0
# export VERSION_K8S_PAR_DEFAUT=v1.10.5
export VERSION_K8S=$VERSION_K8S_PAR_DEFAUT

# - ---
# - Kubernetes affecte un nom pour chaque noeud du cluster: cette variable
#   d'environnement permettra de fixer la valeur de ce "node-name", notamment
#   celui-ci doit être différent selon qu'il s'agit d'un maître ou d'un esclave.
# - 
# - ---
# - Les maîtres utilisent l'option [--node-name] de [kubeadm init] pour faire leur set-node-name
# - Les maîtres esclaves utilisent l'option [--hostname-override=$K8S_NODE_NAME] de [kubelet] pour faire leur set-node-name  
export K8S_NODE_NAME_PAR_DEFAUT=tryphon-$RANDOM
# export K8S_NODE_NAME_PAR_DEFAUT=tournesol
export K8S_NODE_NAME=$K8S_NODE_NAME_PAR_DEFAUT

# - pour POD NETWORK: FLANNEL
# export POD_NETWORK_CIDR
export POD_NETWORK_CIDR_PAR_DEFAUT="10.244.0.0/16"
export POD_NETWORK_CIDR=$POD_NETWORK_CIDR_PAR_DEFAUT

# - pour PROXY HTTP éventuel
# export SRV_PROXY_HTTP_DE_LINFRA
# export SRV_PROXY_HTTP_DE_LINFRA_PAR_DEFAUT=htpp://srv-proxy-de-votre-infra:8080
# SRV_PROXY_HTTP_DE_LINFRA=$SRV_PROXY_HTTP_DE_LINFRA_PAR_DEFAUT

export FICHIER_STDOUT_KUBEADM_INIT_MASTER=$MAISON/stdout-stderr-kubeadm-init.master

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
################						FONCTIONS						######################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quelle est l'adresse IP, et le numéro de port IP, dans l'hôte réseau, que le noeud K8S utilisera
# pour publier l'API de management K8S
#
demander_addrIP () {

	echo "Quelle adresse IP souhaitez-vous que L'API K8S utilise sur cette machine?"
	echo "Cette adresse est à  choisir parmi:"
	echo " "
	ip addr|grep / |grep "inet"
	echo " "
	echo " (Par défaut, l'adresse IP utilisée par l'API Kubernetes sera [$ADRESSE_IP_K8S_API_SERVER_PAR_DEFAUT]) "
	read ADRESSE_IP_CHOISIE
	if [ "x$ADRESSE_IP_CHOISIE" = "x" ]; then
          ADRESSE_IP_CHOISIE=$ADRESSE_IP_K8S_API_SERVER_PAR_DEFAUT
	fi
	
	ADRESSE_IP_K8S_API_SERVER=$ADRESSE_IP_CHOISIE
}

# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel est le numéro de port IP, dans l'hôte réseau, que le noeud K8S utilisera
# pour publier l'API de management K8S
#
demander_noPortIP () {

        echo "Quel numéro de port IP souhaitez-vous que L'API K8S utilise sur cette machine?"
        echo "Vous pouvez par exemple, choisir ce numéro de port entre 1000 et 65 535."
        echo "Bien évidemment, ce numéro de port ne doit pas être déjà utilisé par une autre application."
        echo " "
        echo " (Par défaut, le numéro de port utilsié par l'API Kubernetes sera [$NO_PORT_IP_K8S_API_SERVER_PAR_DEFAUT]) "
        read NO_PORT_CHOISIT
        if [ "x$NO_PORT_CHOISIT" = "x" ]; then
          NO_PORT_CHOISIT=$NO_PORT_IP_K8S_API_SERVER_PAR_DEFAUT
        fi
        NO_PORT_IP_K8S_API_SERVER=$NO_PORT_CHOISIT
}

# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quelle est la version de Kubernetes à installer
#
demander_versionK8S () {

        echo "Quel numéro de version de Kubernetes souhaitez-vous installer?"
        echo " "
        echo " (Par défaut, la version de Kubernetes sera la version [$VERSION_K8S_PAR_DEFAUT]) "
        echo " "
        read NO_VERSION_CHOISIT
        if [ "x$NO_VERSION_CHOISIT" = "x" ]; then
          NO_VERSION_CHOISIT=$VERSION_K8S_PAR_DEFAUT
        fi
        VERSION_K8S=$NO_VERSION_CHOISIT
}

# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel est inom il souhaite donner à ce noeud du cluster
#
demander_NodeName () {

        echo "Quel nom souhaitez-vous donner à ce noeud du cluster?"
        echo " "
        echo " (Par défaut, le nom de ce noeud de cluster  sera [$K8S_NODE_NAME_PAR_DEFAUT]) "
        echo " "
        read NOM_CHOISIT
        if [ "x$NOM_CHOISIT" = "x" ]; then
          NOM_CHOISIT=$K8S_NODE_NAME_PAR_DEFAUT
        fi
        K8S_NODE_NAME=$NOM_CHOISIT
}

# --------------------------------------------------------------------------------------------------------------------------------------------
# Cette fonction permet de demander interactivement à l'utilisateur du
# script, quel est inom il souhaite donner à ce noeud du cluster
#
demander_CIDR_NetID_PrPodNetwork () {

        echo "Quel sous-réseau souhaitez-vous attribuer au pod network Kubernetes?"
        echo " "
        echo " (Par défaut, ce sera [$POD_NETWORK_CIDR_PAR_DEFAUT]) "
        echo " "
        read CIDR_NET_ID_CHOISIT
        if [ "x$CIDR_NET_ID_CHOISIT" = "x" ]; then
          CIDR_NET_ID_CHOISIT=$POD_NETWORK_CIDR_PAR_DEFAUT
        fi
        POD_NETWORK_CIDR=$CIDR_NET_ID_CHOISIT
}

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
#################                                                OPERATIONS                                              #####################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

cd $MAISON

# - Partie Interactive - #
demander_addrIP
demander_noPortIP
demander_versionK8S
demander_NodeName
demander_CIDR_NetID_PrPodNetwork

echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ------------ PROVISION NOEUD KUBERNETES : ---------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ------------ Voulez-vous transformer ce noeud en tant que maître, ou en tant qu'esclave, du cluster kubernetes?"
echo "Pressez \"m\" ou\"M\" (pour maître, par défaut ce sera esclave), puis pressez la touche \"Entrée\""
echo ""
read CHOIX_UTILISATEUR

# - Fin partie interactive


# - DEBUG
# echo "{DEBUG+operations:[VERSION_K8S=$VERSION_K8S]}"
# echo "Pressez une touche pour reprendre l'exécution de la recette"
# read

# - DEBUG

# - Pas le choix: obligé de faire une subtitution dans le script ./installation-k3s-k8s.sh
rm -f installation-k3s-k8s.sh
cp installation-k3s-k8s.sh.template installation-k3s-k8s.sh
sed -i "s/VAL_VERSION_K8S/$VERSION_K8S/g" ./installation-k3s-k8s.sh 
# - autorisations d'exécution
sudo chmod +x ./*.sh
sudo chmod +x ./masters/*.sh
sudo chmod +x ./workers/*.sh
# - désactivation SELinux
sudo ./desactivation-se-linux.sh
# - reste des opérations communes aux "masters" et "workers"
sudo ./config-packg-mngr-repo-officiel-k8s.sh && sudo ./installation-k3s-k8s.sh && sudo ./test3-config-iptables-pr-kubelet.sh && sudo ./test4-desactivation-swap-pr-k8S-nodes.sh 
# - début des différences de provision / configuration
if [ "x$CHOIX_UTILISATEUR" = "x" ]
then
        $MAISON/workers/rejoindre-cluster.sh
        echo " ------------ ++ Cette machine va être transformée en esclave du cluster K8S: $HOSTNAME"
#        echo " ------------ ++ -- l'API Kubernetes sera liée à l'adresse IP: $ADRESSE_IP_K8S_API_SERVER  "
#        echo " ------------ ++ -- l'API Kubernetes sera liée au numéro de port IP: $NO_PORT_IP_K8S_API_SERVER "
else
        $MAISON/masters/faire-le-pull-des-images-conteneurs-k8s.sh
        $MAISON/masters/creer-cluster-k8s-init-master.sh
        $MAISON/masters/installer-configuration-kubectl.sh
        $MAISON/masters/configurer-pod-network.sh
        echo " ------------ ++ Cette machine va être transformée en maître du cluster K8S, et: "
        echo " ------------ ++ -- l'API Kubernetes sera liée à l'adresse IP: $ADRESSE_IP_K8S_API_SERVER  "
        echo " ------------ ++ -- l'API Kubernetes sera liée au numéro de port IP: $NO_PORT_IP_K8S_API_SERVER "
        echo " ------------ ++ --  "
        echo " ------------ ++ --  "
        echo " ------------ ++ --  De plus, voici l'instruction à exécuter pour rejoindre ce maître dans son cluster:"
		cat $FICHIER_STDOUT_KUBEADM_INIT_MASTER |grep kubeadm |grep join
		# et il sera possible de faire d'autre manipûlations de chaînes de caractère pour ajouter le nodename au join
        echo " ------------ ++ --  "
        echo " ------------ ++ --  "
        echo " ------------ ++ --  "
fi
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
