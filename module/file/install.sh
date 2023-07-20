#!/usr/bin/env bash

echo "Preparing installation ..."

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update -qq

# Install JRE
echo "Installing JRE ..."
sudo apt install -y default-jre

# Install and start Jenkins
echo "Installing and start jenkins ..."
sudo apt install -y jenkins
sudo systemctl start jenkins

# Install git
echo "Installing git ..."
sudo apt install -y git

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

echo "Install Docker engine"
sudo apt install -y docker.io
usermod -aG docker ubuntu
systemctl start docker


#sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
#sudo sh -c \"iptables-save > /etc/iptables.rules\"
#echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
#echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
#sudo apt-get -y install iptables-persistent
#sudo ufw allow 8080