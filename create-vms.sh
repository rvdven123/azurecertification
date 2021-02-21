export RG=javeerg
export location=eastus
export PW=norjav01@92412

#1
az group create --name $RG --location $location

#2
az network vnet create \
    --resource-group $RG \
    --name MyVNet1 \
    --address-prefix 10.10.0.0/16 \
    --subnet-name FrontendSubnet \
    --subnet-prefix 10.10.1.0/24
#3
az network vnet subnet create \
    --address-prefixes 10.10.2.0/24 \
    --name BackendSubnet \
    --resource-group $RG \
    --vnet-name MyVNet1

#4
az vm create \
    --resource-group $RG \
    --name FrontendVM \
    --vnet-name MyVNet1 \
    --subnet FrontendSubnet \
    --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password $PW

#5
az vm extension set \
    --publisher Microsoft.Compute \
    --name CustomScriptExtension \
    --vm-name FrontendVM \
    --resource-group $RG \
    --settings '{"commandToExecute":"powershell.exe Install-WindowsFeature -Name Web-Server"}' \
    --no-wait        

#6
 az vm create \
    --resource-group $RG \
    --name BackendVM \
    --vnet-name MyVNet1 \
    --subnet BackendSubnet \
    --image Win2019Datacenter \
    --admin-username azureuser \
    --admin-password $PW

#7
 az vm extension set \
    --publisher Microsoft.Compute \
    --name CustomScriptExtension \
    --vm-name BackendVM \
    --resource-group $RG \
    --settings '{"commandToExecute":"powershell.exe Install-WindowsFeature -Name Web-Server"}' \
    --no-wait

#8
 az network nsg create \
    --name MyNsg \
    --resource-group $RG

#9
az network nsg rule create \
    --resource-group $RG \
    --name MyNSGRule \
    --nsg-name MyNsg \
    --priority 4096 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 443 3389 \
    --access Deny \
    --protocol TCP \
    --direction Inbound \
    --description "Deny from specific IP address ranges on 80, 443 and 3389."

#10
az network vnet subnet update \
    --resource-group $RG \
    --name BackendSubnet \
    --vnet-name MyVNet1 \
    --network-security-group MyNsg

#11
az network watcher configure \
    --locations $location \
    --enabled true \
    --resource-group $RG

#extra 
#12
az vm extension set \
    --resource-group $RG \
    --vm-name FrontendVM \
    --name NetworkWatcherAgentWindows \
    --publisher Microsoft.Azure.NetworkWatcher --version 1.4                        

#13
az vm extension set \
    --resource-group $RG \
    --vm-name FrontendVM \
    --name NetworkWatcherAgentWindows \
    --publisher Microsoft.Azure.NetworkWatcher --version 1.4                            