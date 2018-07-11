# - 

# export http_proxy=http://proxy:8080
# export https_proxy=http://proxy:8080

WHERE_TO_PULL_FLANNEL_YML_CONF_FROM=https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
curl "$WHERE_TO_PULL_FLANNEL_YML_CONF_FROM" -o ./kube-flannel.yml
sudo kubectl apply -f ./kube-flannel.yml


