#!/bin/bash
# L'objet de ce script, est de s'assurer que seule l'infrastructure
# Bosstek gère les noms d'hôtes réseaux des noeuds du cluster K8S

sudo hostnamectl set-hostname "" --pretty
sudo hostnamectl set-hostname "" --static
sudo hostnamectl set-hostname "" --transitent
