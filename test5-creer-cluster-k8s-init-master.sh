clear
KUBEADM_OPTS="--apiserver-advertise-address=172.19.15.89 "
kubeadm init $KUBEADM_OPTS --kubernetes-version=v1.11.0
