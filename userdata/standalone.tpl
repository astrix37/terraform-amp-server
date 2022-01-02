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

sudo mkdir /data
sudo cp /etc/fstab /etc/fstab.orig
echo 'UUID=${volume_mount_id} /data xfs  defaults,nofail  0  2' | sudo tee -a /etc/fstab
sudo mount /dev/nvme1n1 /data
sudo chown -R amp /data
sudo ln -s /data/.ampdata /home/amp/
sudo -H -u amp bash -c "ampinstmgr stop ads01"

sudo ampinstmgr setupnginx ${instance_dns} 8080
sudo reboot