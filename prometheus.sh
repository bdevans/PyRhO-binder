#!/bin/sh

sudo service docker start
sudo docker build -t pyrho/minimal .

sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8000

export TOKEN=$( head -c 30 /dev/urandom | xxd -p )
sudo docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=proxy \
            jupyter/configurable-http-proxy --default-target http://127.0.0.1:9999 --port=8000 --api-port=8001
sudo docker run --net=host -d -e CONFIGPROXY_AUTH_TOKEN=$TOKEN --name=tmpnb -e CONFIGPROXY_ENDPOINT=http://127.0.0.1:8001 \
           -v /var/run/docker.sock:/docker.sock \
           jupyter/tmpnb python orchestrate.py --image='pyrho/minimal' \
           --redirect-uri="/notebooks/Prometheus_demo.ipynb" \
           --command="jupyter notebook --NotebookApp.base_url={base_path} --ip=0.0.0.0 --port {port} --no-browser"

# docker run --restart=always
# --mem-limit=512m
# --pool-size=4
# --cpu-shares
# --cull-timeout=3600
