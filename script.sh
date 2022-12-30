#!/bin/bash

read -p "Enter password: " pass

setenforce 0

yum install epel-release wget -y
wget -qO- https://get.docker.com/ | sh

systemctl start docker
systemctl enable docker

yum install python3 python3-pip libselinux-python3 git -y
pip3 install --upgrade pip
pip3 install docker-compose

yum install epel-release -y
yum install ansible git -y

rm -rf /awx
git clone -b 17.1.0 https://github.com/ansible/awx.git /awx

sed -i s/"^pg_password=awxpass"/"pg_password=\"${pass}\""/ /awx/installer/inventory
sed -i s/"# admin_password=password"/"admin_password=\"${pass}\""/ /awx/installer/inventory
sed -i s/"^secret_key=awxsecret"/"secret_key=\"${pass}\""/ /awx/installer/inventory

cd /awx/installer

try=1
ansible-playbook -i inventory install.yml 
result=$?

while [ $try -le 3 ] && [ $result -ne 0 ]
do
        echo -e "\n\n###########################\n\n"
        echo "Failed, Retrying"
        echo -e "\n\n###########################\n\n"
        ansible-playbook -i inventory install.yml
        result=$?
        try=$(( $try + 1 ))
done

if [ $result -eq 0 ]
then
        echo -e "\n\n###########################\n\n"
        echo "Success"
        echo -e "\n\n###########################\n\n"
fi
