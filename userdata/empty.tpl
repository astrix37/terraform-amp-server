#! /bin/bash
sudo useradd -d /home/amp -m amp -s /bin/bash

sudo apt-get install software-properties-common dirmngr apt-transport-https
sudo apt-key adv --fetch-keys http://repo.cubecoders.com/archive.key
sudo apt-add-repository "deb http://repo.cubecoders.com/ debian/"
sudo apt update

sudo apt-get -y install nginx certbot python3-certbot-nginx

sudo ufw allow from any to any port 8080 proto tcp
sudo apt -y install ampinstmgr

sudo apt-get -y install openjdk-16-jdk