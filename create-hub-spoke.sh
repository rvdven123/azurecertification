az group create -l westus -n javee

az deployment group create \
    --resource-group javee \
    --template-uri https://raw.githubusercontent.com/MicrosoftDocs/mslearn-hub-and-spoke-network-architecture/master/azuredeploy.json