#!/bin/bash

# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
################                                                ENVIRONNEMENT                                            #####################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

# export MAISON=`pwd`
# export ADRESSE_IP_K8S_API_SERVER_PAR_DEFAUT=0.0.0.0
# export NO_PORT_IP_K8S_API_SERVER_PAR_DEFAUT=6443
# export VERSION_K8S_PAR_DEFAUT=v1.11.0

# - cf. [https://github.com/kubernetes/kubeadm/issues/584]
# "I figured this one out. It seems that in addition to the --node-name option for kubeadm you also
# need to set --hostname-override for kubelet. I had assumed kubeadm would handle that."
# -
# - Les maîtres utilisent l'option [--node-name] de [kubeadm init] pour faire leur set-node-name
# - Les maîtres esclaves utilisent l'option [--hostname-override=$K8S_NODE_NAME] de [kubelet] pour faire leur set-node-name 
# export K8S_NODE_NAME

# - pour POD NETWORK: FLANNEL 
# export POD_NETWORK_CIDR=10.244.0.0/16
# --------------------------------------------------------------------------------------------------------------------------------------------
##############################################################################################################################################
################                                                OPERATIONS                                            ########################
##############################################################################################################################################
# --------------------------------------------------------------------------------------------------------------------------------------------

clear

echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ------------ PROVISION TERMINEE : ---------------- "
echo " ------------ ++ kubeadm ---------------- "
echo " ------------ ++ kubectl ---------------- "
echo " ------------ ++ kubelet ---------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "
echo " ---------------------------------------------------- "


KUBEADM_OPTS=""
KUBEADM_OPTS="$KUBEADM_OPTS --node-name=$K8S_NODE_NAME"
# -
# - cf. [https://github.com/kubernetes/kubeadm/issues/584]
# "I figured this one out. It seems that in addition to the --node-name option for kubeadm you also
# need to set --hostname-override for kubelet. I had assumed kubeadm would handle that."
# - mais ceci concerne les kubelet, pas le node, ni kubeadm. Donc on oublie
# -
# KUBEADM_OPTS="$KUBEADM_OPTS  --hostname-override=$K8S_NODE_NAME"
KUBEADM_OPTS="$KUBEADM_OPTS --kubernetes-version=v$VERSION_K8S"
KUBEADM_OPTS="$KUBEADM_OPTS --apiserver-advertise-address=$ADRESSE_IP_K8S_API_SERVER"
KUBEADM_OPTS="$KUBEADM_OPTS --apiserver-bind-port=$NO_PORT_IP_K8S_API_SERVER"
KUBEADM_OPTS="$KUBEADM_OPTS --apiserver-bind-port=$NO_PORT_IP_K8S_API_SERVER"
# - pour l'ajout du pod network
KUBEADM_OPTS="$KUBEADM_OPTS --pod-network-cidr=$POD_NETWORK_CIDR"

echo "kubeadm init $KUBEADM_OPTS" >> commande-kubeadm-init.jbl
 
kubeadm init $KUBEADM_OPTS 2>&1 | tee -a $FICHIER_STDOUT_KUBEADM_INIT_MASTER

