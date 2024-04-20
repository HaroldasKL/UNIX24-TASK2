#!/bin/bash
start=$(date +%s)
current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script started"
echo "Current date: $current_date"
echo "Current time: $current_time"
rm ~/.ssh/known_hosts
REMOTE_USER="hakl8025"
ansible-playbook create_vm_playbook.yml --vault-password-file ~/vault_pass.txt



VM_PRIVATE_IP=$(cat ip_address.txt)
read -p "Press anythin when ssh key will be copied to the machine ${VM_PRIVATE_IP}: " tmp
ssh-copy-id -i ~/.ssh/id_rsa.pub "hakl8025@${VM_PRIVATE_IP}"

sudo truncate -s 0 /etc/ansible/hosts
echo '[LAMP_HOST]' | sudo tee -a /etc/ansible/hosts >/dev/null
echo "${VM_PRIVATE_IP} ansible_user=${REMOTE_USER}" | sudo tee -a /etc/ansible/hosts >/dev/null

ansible-playbook copy_scripts_playbook.yml --vault-password-file ~/vault_pass.txt

end=$(date +%s)
runtime=$((end-start))
echo "Script took $((runtime / 60)) minutes and $((runtime % 60)) seconds to run."

current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
echo "Script ended"
echo "Current date: $current_date"
echo "Current time: $current_time"
