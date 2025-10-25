#!/bin/bash

set -e
set -u
set -o pipefail

## ubuntu2404 vs donweb-prod
# ssh-copy-id -i ../provision/.ssh/id_rsa.pub -p 22 -i "ubuntu2404/.vagrant/machines/default/virtualbox/private_key" vagrant@192.168.56.103

ssh -p 22 -i "./ubuntu2404/.vagrant/machines/default/virtualbox/private_key" vagrant@192.168.56.103
scp -P 22 -i "./ubuntu2404/.vagrant/machines/default/virtualbox/private_key" ../provision/.ssh/id_rsa.pub vagrant@192.168.56.103:
ssh -p 22 -i "./ubuntu2404/.vagrant/machines/default/virtualbox/private_key" vagrant@192.168.56.103 "mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; cat ~/id_rsa.pub >> ~/.ssh/authorized_keys; rm -f ~/id_rsa.pub"
