# SET THE NAME FOR YOUR RESOURCE GROUP AND VMS.  USE LOWER CASE AND KEEP IT SHORT!  EG PRD123

$demoname = "raflab"

New-AzureRmResourceGroup -Name $demoname -Location "Australia East"

# CREATE DOMAIN CONTROLLER
    New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\azure-quickstart-templates\active-directory-new-domain\azuredeploy.json" -TemplateParameterFile "C:\scripts\azure-quickstart-templates\active-directory-new-domain\azuredeploy.parameters.json" -verbose -dnsPrefix "$demoname-ad"

#DOMAIN JOIN VM
    New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.json" -TemplateParameterFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.parameters.json" -verbose -dnslabelprefix "$demoname-sql"

#DOMAIN JOIN VM
    New-AzureRmResourceGroupDeployment -Name $demoname -ResourceGroupName $demoname -TemplateFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.json" -TemplateParameterFile "C:\scripts\azure-quickstart-templates\201-vm-domain-join\azuredeploy.parameters.json" -verbose -dnslabelprefix "$demoname-scom"

