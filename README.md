Prometheus: Modelling as a Service
==================================

This is a repository for building a customised tmpnb server for optogenetics with PyRhO installed and configured.

Quickstart Prometheus
---------------------
sudo apt-get update && sudo apt-get upgrade
Create an account to run the portal and disable root access

adduser monty
gpasswd -a monty sudo
sudo nano /etc/ssh/sshd_config
>> PermitRootLogin no
service ssh restart

git clone https://github.com/ProjectPyRhO/Prometheus
chown -R monty:monty Prometheus/*
cd Prometheus
chmod a+x *.sh
./setup_docker.sh
./prometheus.sh


Interactive Docker image
------------------------

To run the PyRhO docker image:

sudo service docker start
sudo docker build -t pyrho/minimal .

docker run -i -t pyrho/minimal /bin/bash

Useful commands
---------------

# Clean docker images
sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)

# Check logs
sudo docker logs proxy
sudo docker logs tmpnb
sudo iptables -L
