#!/bin/bash
# Update packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker apt repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Update again after adding repo
sudo apt-get update -y

# Install Docker Engine & CLI
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add default user to docker group (so no sudo needed)
sudo usermod -aG docker ubuntu
