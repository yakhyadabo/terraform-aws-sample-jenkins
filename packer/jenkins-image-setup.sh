#!/usr/bin/env bash

# Author: Yakhya Dabo
# Date: 24/07/2023

export DEBIAN_FRONTEND="noninteractive"

echo "START jenkins-image-setup.sh"

sudo apt install software-properties-common
sudo add-apt-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get -y install ansible

ansible --version

echo "END jenkins-image-setup.sh"

