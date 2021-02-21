
#Create nva VM in DMZ subnet
az vm create \
    --resource-group [sandbox resource group name] \
    --name nva \
    --vnet-name vnet \
    --subnet dmzsubnet \
    --image UbuntuLTS \
    --admin-username azureuser \
    --admin-password <password>

#Ophalen NIC ID van de nvm VM
NICID=$(az vm nic list \
    --resource-group [sandbox resource group name] \
    --vm-name nva \
    --query "[].{id:id}" --output tsv)

echo $NICIDNVAIP="$(az vm list-ip-addresses \
    --resource-group [sandbox resource group name] \
    --name nva \
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)"

echo $NVAIP

#Ophalen naam van de NIC
NICNAME=$(az vm nic show \
    --resource-group [sandbox resource group name] \
    --vm-name nva \
    --nic $NICID \
    --query "{name:name}" --output tsv)

echo $NICNAME

#Ophalen IP van de nva VM
NVAIP="$(az vm list-ip-addresses \
    --resource-group [sandbox resource group name] \
    --name nva \
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)"

echo $NVAIP

#Enable forwarden van verkeer op de VM
ssh -t -o StrictHostKeyChecking=no azureuser@$NVAIP 'sudo sysctl -w net.ipv4.ip_forward=1; exit;'

#Maak een vm init script met inhoud
code cloud-init.txt
#cloud-config -> #Install traceroute
package_upgrade: true
packages:
   - inetutils-traceroute

#Maak Publiek Openbare VM
az vm create \
    --resource-group [sandbox resource group name] \
    --name public \
    --vnet-name vnet \
    --subnet publicsubnet \
    --subnet-address-prefix 10.0.2.0/24 \
    --image UbuntuLTS \
    --admin-username azureuser \
    --no-wait \
    --custom-data cloud-init.txt \
    --admin-password <password>


#Maak Persoonlijke / Private VM
az vm create \
    --resource-group [sandbox resource group name] \
    --name private \
    --vnet-name vnet \
    --subnet privatesubnet \
    --image UbuntuLTS \
    --admin-username azureuser \
    --no-wait \
    --custom-data cloud-init.txt \
    --admin-password <password>

#Watch aanmaken van vms
watch -d -n 5 "az vm list \
    --resource-group [sandbox resource group name] \
    --show-details \
    --query '[*].{Name:name, ProvisioningState:provisioningState, PowerState:powerState}' \
    --output table"

#Haal publiek ip op van de publieke vm
PUBLICIP="$(az vm list-ip-addresses \
    --resource-group [sandbox resource group name] \
    --name public \
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)"

echo $PUBLICIP

#Haal het publiek ip adres op van de private/persoonlijke vm
PRIVATEIP="$(az vm list-ip-addresses \
    --resource-group [sandbox resource group name] \
    --name private \
    --query "[].virtualMachine.network.publicIpAddresses[*].ipAddress" \
    --output tsv)"

echo $PRIVATEIP

#Volg verkeer van de private/persoonlijke vm
ssh -t -o StrictHostKeyChecking=no azureuser@$PUBLICIP 'traceroute private --type=icmp; exit'

#traceroute to private.kzffavtrkpeulburui2lgywxwg.gx.internal.cloudapp.net (10.0.1.4), 64 hops max
#1   10.0.2.4  0.710ms  0.410ms  0.536ms
#2   10.0.1.4  0.966ms  0.981ms  1.268ms
#Connection to 52.165.151.216 closed.

#Volg het verkeer van prive naar openbaar
ssh -t -o StrictHostKeyChecking=no azureuser@$PRIVATEIP 'traceroute public --type=icmp; exit'

#traceroute to public.kzffavtrkpeulburui2lgywxwg.gx.internal.cloudapp.net (10.0.0.4), 64 hops max
#1   10.0.0.4  1.095ms  1.610ms  0.812ms
#Connection to 52.173.21.188 closed.