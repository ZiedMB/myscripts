az login

# If multiple subscription, set the one where VM and KeyVault are.
az account set -s '<YourSubscriptionID>'

# Define VM variables
rgname="NetLab"
VMName='redhatlab'
loc='westeurope'

# Define the name of the KeyVault and its Resource Group name that will be created.
keyvault_name='myzikey'
KVRG='bounce'

# Define the name of the Service Principal that will be created.
SPName='spzyky'

# Define the name of the KEK
KVKeyName='KEKZyky'

# Let's check first the status of the VM
az vm show -g $rgname -n $VMName -d

# If not already done, registre KV provider and then check if already existing
az provider register -n Microsoft.KeyVault
az provider show -n Microsoft.KeyVault

# Check if KeyVault RG already exists
az group show --name $KVRG

# If RG is missing, create it
az group create --name $KVRG --location $loc

# Create KeyVault and Key
az keyvault create --name $keyvault_name --resource-group $KVRG --location $loc --enabled-for-disk-encryption True
az keyvault key create --vault-name $keyvault_name --name $KVKeyName --protection software
KEKUri=$(az keyvault key show --vault-name $keyvault_name --name $KVKeyName --query [key.kid] -o tsv)
KEKV=$(az keyvault show -g $KVRG -n $keyvault_name --query [id] -o tsv)

# Create SP with default permissions (NOTE DOWN and save the $pw for future use. Password is only shown during SP creation)
appAndPw=$(az ad sp create-for-rbac -n $SPName --query [appId,password] -o tsv)
aadClientID=`echo $appAndPw | awk '{print $1}'`
pw=`echo $appAndPw | awk '{print $2}'`

# Grant AAD Application the rights to use the KeyVault for ADE purpose
az keyvault set-policy --name $keyvault_name --spn $aadClientID --key-permissions wrapKey --secret-permissions set

# Now, enable the encryption - This enable for "All" the disks
az vm encryption enable --resource-group $rgname --name $VMName --aad-client-id $aadClientID --aad-client-secret $pw --key-encryption-keyvault $KEKV --key-encryption-key $KEKUri --disk-encryption-keyvault $keyvault_name --volume-type all

# Check encryption
az vm encryption show --resource-group $rgname --name $VMName


