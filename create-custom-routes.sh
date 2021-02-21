RG="Bla"

# Create route table "publictable"
az network vhub route-table create \
    --name publictable \
    --resource-group $RG \
    --disable-bgp-route-propagation false

# Create route to "VirtualAppliance" in "dmzsubnet" in "publictable"
az network vhub route-table route create \
    --route-table-name publictable \
    --resource-group $RG \
    --name productionsubnet \
    --address-prefix 10.0.1.0/24 \
    --next-hop-type VirtualAppliance \
    --next-hop-ip-address 10.0.2.4

#Create vnet "vnet" with subnet "publicsubnet"
az network vnet create \
    --name vnet \
    --resource-group [sandbox resource group name] \
    --address-prefix 10.0.0.0/16 \
    --subnet-name publicsubnet \
    --subnet-prefix 10.0.0.0/24

#Create subnet "privatesubnet" in vnet "vnet"
az network vnet subnet create \
    --name privatesubnet \
    --vnet-name vnet \
    --resource-group [sandbox resource group name] \
    --address-prefix 10.0.1.0/24

#Create subnet "dmzsubnet" in vnet "vnet"
az network vnet subnet create \
    --name dmzsubnet \
    --vnet-name vnet \
    --resource-group [sandbox resource group name] \
    --address-prefix 10.0.2.0/24

#List subnets
az network vnet subnet list \
    --resource-group [sandbox resource group name] \
    --vnet-name vnet \
    --output table

#Assocation route table "publictable" with subnet "publicsubnet"
```azurecli
 az network vnet subnet update \
     --name publicsubnet \
     --vnet-name vnet \
     --resource-group [sandbox resource group name] \
     --route-table publictable
 ```

