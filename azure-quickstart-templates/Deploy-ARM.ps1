﻿# SET THE NAME FOR YOUR RESOURCE GROUP AND VMS.  USE LOWER CASE AND KEEP IT SHORT!  EG PRD123

$demoname = "sealab"

$domainname = "sea.lab"

$username = "boss"
`
$password = ConvertTo-SecureString "P@55w0rd12345" -AsPlainText -Force

New-AzureRmResourceGroup -Name $demoname -Location "Southeast Asia"

# CREATE DOMAIN CONTROLLER
    New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\scripts\azure-quickstart-templates\active-directory-new-domain\azuredeploy.json" -TemplateParameterFile "C:\scripts\scripts\azure-quickstart-templates\active-directory-new-domain\azuredeploy.parameters.json" -verbose `
    -dnsPrefix "$demoname-ad" -adminUsername $username -adminPassword $password -domainName $domainname -adVMName "SEADC01"


#NEW SQL Server DOMAIN JOIN
    New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\scripts\azure-quickstart-templates\new-sql-domain-join\azuredeploy.json" `
    -vmName "SEASQL01" -domainPassword $domainpassword -vmAdminUsername $username -domainUsername $username -domainToJoin $demoname -vmAdminPassword $password -verbose 

    
#DOMAIN JOIN VM
New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.json" `
-TemplateParameterFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.parameters.json" -verbose `
-dnslabelprefix "$demoname-sql" -domainPassword $domainpassword -vmAdminUsername $username -domainUsername $username -domainToJoin $demoname -vmAdminPassword $password

#DOMAIN JOIN VM
    New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.json" -TemplateParameterFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.parameters.json" -verbose `