#!/bin/bash

## ./provision/setup_ubuntu.sh 

set -e
set -u
set -o pipefail

sudo apt update
sudo apt -y install software-properties-common
sudo add-apt-repository -y --update ppa:ansible/ansible
sudo apt -y install ansible

sudo apt -y install python3 python3-pip
