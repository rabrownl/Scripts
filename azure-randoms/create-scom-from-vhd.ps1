
$disk1 = "https://scom1711storageaccount.blob.core.windows.net/mycontainer/SCOM_Preview_1711_VHD"




$rgName = "SCOM1711"
$location = "Southeast Asia"

$ipName = "myIP"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic


$nsgName = "myNsg"

$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name myRdpRule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName -Location $location  -Name $nsgName -SecurityRules $rdpRule


$vmName = "SCOM1711"
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_D4"


$subnetName = "mySubNet"
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $nsg


$vnetName = "myVnetName"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location `
    -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet 


$nicName = "SCOM1711Nic"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id


$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id


$osDisk = New-AzureRmDisk -DiskName "SCOM1711OSDisk" -Disk `
    (New-AzureRmDiskConfig -AccountType StandardLRS  -Location $location -CreateOption Import -SourceUri $disk1)  -ResourceGroupName $rgName


$vm = Set-AzureRmVMOSDisk -VM $vmConfig -ManagedDiskId $osDisk.Id -StorageAccountType StandardLRS -DiskSizeInGB 128 -CreateOption Attach -Windows

#Create the new VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm