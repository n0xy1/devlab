You made it this far, the struggle continues.

Now run in powershell: " .\tf_enable_remoting.ps1"
(you probably need to manually enable winrm service on the clients)

and finally (in WSL) run:
ansible-playbook -i .\tf_ansible_inventory.yml ./ANSI/main.yml
ansible-playbook -i .\tf_ansible_inventory.yml ./ANSI/client-join.yml

