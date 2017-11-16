# SET THE NAME FOR YOUR RESOURCE GROUP AND VMS.  USE LOWER CASE AND KEEP IT SHORT!  EG PRD123

#$subscriptionid = "c73e33a6-6855-4123-a017-d95432c640ce"

$MSDNSubscription = "f5781d84-3f99-4314-a3fe-b342f32023a3"

Select-AzureRmSubscription -SubscriptionId $MSDNSubscription

$demoname = "sealab"

$domainname = "sea.lab"

$username = "boss"
`
$password = ConvertTo-SecureString "P@55w0rd12345" -AsPlainText -Force

New-AzureRmResourceGroup -Name $demoname -Location "Southeast Asia"

# CREATE DOMAIN CONTROLLER
 $output = New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\scripts\azure-quickstart-templates\active-directory-new-domain\azuredeploy.json"`
    -TemplateParameterFile "C:\scripts\scripts\azure-quickstart-templates\active-directory-new-domain\azuredeploy.parameters.json" -verbose `
   -adminUsername $username -adminPassword $password -domainName $domainname -adVMName "DC01SEA"


#NEW SQL Server DOMAIN JOIN
    New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\scripts\azure-quickstart-templates\new-sql-domain-join\azuredeploy.json" `
    -vmName "SQL01SEA" -domainPassword $password -vmAdminUsername $username -domainUsername $username -domainToJoin $domainname -vmAdminPassword $password `
    -existingVNETName "adVNET" -existingSubnetName "adSubnet" -storageAccountName $output.outputs.Values.Value -verbose 


#DOMAIN JOIN VM
New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.json" `
-TemplateParameterFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.parameters.json" -verbose `
 -domainPassword $password -vmAdminUsername $username -domainUsername $username -domainToJoin $demoname -vmAdminPassword $password

#DOMAIN JOIN VM
 #   New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.json" -TemplateParameterFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.parameters.json" -verbose 