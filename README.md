Prometheus: Modelling as a Service
==================================

This is a repository for building a customised tmpnb server for optogenetics with PyRhO installed and configured.

Quickstart Prometheus
---------------------

git clone https://github.com/ProjectPyRhO/Prometheus

./prometheus.sh


Interactive Docker image
------------------------

To run the PyRhO docker image:

sudo service docker start
sudo docker build -t pyrho/minimal .

docker run -i -t pyrho/minimal /bin/bash
