#!/usr/bin/env bash

##!/bin/bash -e
exec 3>&1 4>&2
exec 1>/var/log/jenkins-init.log 2>&1

echo "Preparing installation ..."

# Setup git
echo "Setting up SSH key ..."
JENKINS_HOME=/var/lib/jenkins
mkdir $JENKINS_HOME/.ssh
touch $JENKINS_HOME/.ssh/known_hosts
ssh-keygen -t rsa -b 2048 -f $JENKINS_HOME/.ssh/id_rsa -N ''
chmod 700 $JENKINS_HOME/.ssh
chmod 644 $JENKINS_HOME/.ssh/id_rsa.pub
chmod 600 $JENKINS_HOME/.ssh/id_rsa
chown -R jenkins:jenkins $JENKINS_HOME/.ssh

#echo "Install Docker engine"
#sudo apt install -y docker.io
#usermod -aG docker ubuntu
#systemctl start docker



echo "Mount Location: ${MOUNT_LOCATION}"
echo "Mount Target: ${MOUNT_TARGET}"

# Create the directory where to mount EFS
sudo mkdir -p "${MOUNT_LOCATION}"

# Mount EFS
sudo mount \
    -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport \
    "${MOUNT_TARGET}":/ "${MOUNT_LOCATION}"

# mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0a9ce57c106e408fa.efs.us-east-1.amazonaws.com:/ /var/lib/jenkins

# Make Jenkins the owner of the EFS directory
sudo chown jenkins:jenkins "${MOUNT_LOCATION}"

# If EFS does not have jenkins mounted, reinstall Jenkins.
#if [ ! -e /var/lib/jenkins/jobs ]
#then
#    echo "Initial EFS Deployment... Reinstalling Jenkins"
#    sudo apt-get --assume-yes install --reinstall jenkins
#fi

sudo echo "${MOUNT_TARGET}:/ ${MOUNT_LOCATION} nfsdefaults,vers=4.1 0 0" >> /etc/fstab

# Since we use https
sudo sed -i -e 's/https/http/g' /var/lib/jenkins/hudson.model.UpdateCenter.xml

# Start Jenkins
echo "Starting Jenkins ..."
# TODO: Don't run jenkins as root
sudo systemctl start jenkins

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

#sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
#sudo sh -c \"iptables-save > /etc/iptables.rules\"
#echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
#echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
#sudo apt-get -y install iptables-persistent
#sudo ufw allow 8080