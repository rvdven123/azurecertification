az network public-ip create \
    --resource-group MyReGr \
    --name PIP-VNG-Azure-VNet-1 \
    --allocation-method Dynamic

az network vnet-gateway create \
    --resource-group MyReGr \
    --name VNG-Azure-VNet-1 \
    --public-ip-address PIP-VNG-Azure-VNet-1 \
    --vnet Azure-VNet-1 \
    --gateway-type Vpn \
    --vpn-type RouteBased \
    --sku VpnGw1 \
    --no-wait

az network public-ip create \
    --resource-group MyReGr \
    --name PIP-VNG-HQ-Network \
    --allocation-method Dynamic

az network vnet-gateway create \
    --resource-group MyReGr \
    --name VNG-HQ-Network \
    --public-ip-address PIP-VNG-HQ-Network \
    --vnet HQ-Network \
    --gateway-type Vpn \
    --vpn-type RouteBased \
    --sku VpnGw1 \
    --no-wait

watch -d -n 5 az network vnet-gateway list \
    --resource-group MyReGr \
    --output table

az network vnet-gateway list \
    --resource-group MyReGr \
    --query "[?provisioningState=='Succeeded']" \
    --output table

PIPVNGAZUREVNET1=$(az network public-ip show \
    --resource-group MyReGr \
    --name PIP-VNG-Azure-VNet-1 \
    --query "[ipAddress]" \
    --output tsv)

az network local-gateway update \
    --resource-group MyReGr \
    --name LNG-Azure-VNet-1 \
    --gateway-ip-address $PIPVNGAZUREVNET1

PIPVNGHQNETWORK=$(az network public-ip show \
    --resource-group MyReGr \
    --name PIP-VNG-HQ-Network \
    --query "[ipAddress]" \
    --output tsv)

SHAREDKEY=mysharedkey

az network vpn-connection create \
    --resource-group MyReGr \
    --name Azure-VNet-1-To-HQ-Network \
    --vnet-gateway1 VNG-Azure-VNet-1 \
    --shared-key $SHAREDKEY \
    --local-gateway2 LNG-HQ-Network

az network vpn-connection create \
    --resource-group MyReGr \
    --name HQ-Network-To-Azure-VNet-1  \
    --vnet-gateway1 VNG-HQ-Network \
    --shared-key $SHAREDKEY \
    --local-gateway2 LNG-Azure-VNet-1

az network vpn-connection show \
    --resource-group MyReGr \
    --name Azure-VNet-1-To-HQ-Network  \
    --output table \
    --query '{Name:name,ConnectionStatus:connectionStatus}'


az network vpn-connection show \
    --resource-group MyReGr \
    --name HQ-Network-To-Azure-VNet-1  \
    --output table \
    --query '{Name:name,ConnectionStatus:connectionStatus}'

az group delete --name MyReGr

az network local-gateway update \
    --resource-group MyReGr \
    --name LNG-HQ-Network \
    --gateway-ip-address $PIPVNGHQNETWORK
