$disk1 = "https://rafaela.blob.core.windows.net/vhds/rafaelab2-SCOM11-2015-11-08.vhd"
$disk2 = "https://rafaela.blob.core.windows.net/vhds/rafaelab2-SCOM11-disk2.vhd"

$storage1key = "Z9jGZez2ZTeTjL79Ta23xLnaJPVTHT/qwCD4zl4MoBIkhZnXLd+LxHCBKSSTW18nXg8agiXQpipWXw+0m4EvVQ=="

$storage1url = "DefaultEndpointsProtocol=https;AccountName=rafaela;AccountKey=Z9jGZez2ZTeTjL79Ta23xLnaJPVTHT/qwCD4zl4MoBIkhZnXLd+LxHCBKSSTW18nXg8agiXQpipWXw+0m4EvVQ==;EndpointSuffix=core.windows.net"

$storage2Key = "cA/4SU7WxTWAi/WHgWUYp42Af+mGQYHIFIQZnKuMcWad70ED/V/ZD0H8x3xQ2+CYHwUyqVvhLHjNFI9jyp4z6Q=="
$storage2url = "DefaultEndpointsProtocol=https;AccountName=scomlabaustraliaeast618;AccountKey=cA/4SU7WxTWAi/WHgWUYp42Af+mGQYHIFIQZnKuMcWad70ED/V/ZD0H8x3xQ2+CYHwUyqVvhLHjNFI9jyp4z6Q==;EndpointSuffix=core.windows.net"

<#
.\AzCopy.exe /Source:https://rafaela.blob.core.windows.net/vhds/ `
  /Dest:https://scomlabaustraliaeast618.blob.core.windows.net/vhds `
  /SourceKey:Z9jGZez2ZTeTjL79Ta23xLnaJPVTHT/qwCD4zl4MoBIkhZnXLd+LxHCBKSSTW18nXg8agiXQpipWXw+0m4EvVQ== /DestKey:cA/4SU7WxTWAi/WHgWUYp42Af+mGQYHIFIQZnKuMcWad70ED/V/ZD0H8x3xQ2+CYHwUyqVvhLHjNFI9jyp4z6Q== `
  /Pattern:rafaelab2-SCOM11-2015-11-08.vhd
#>

<#$rgName = "SCOM-LAB-AustraliaEast"
$location = "AustraliaEast"

$ipName = "myIP"
$pip = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic


$nsgName = "myNsg"

$rdpRule = New-AzureRmNetworkSecurityRuleConfig -Name myRdpRule -Description "Allow RDP" `
    -Access Allow -Protocol Tcp -Direction Inbound -Priority 110 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange 3389

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName -Location $location  -Name $nsgName -SecurityRules $rdpRule


$vmName = "SCOM1"
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize "Standard_D4"
#>

$rgName = "SCOM-LAB-AustraliaEast"
$subnetName = "mySubNet"
$singleSubnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24

$location = "Australia East"
$vnetName = "myVnetName"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location `
    -AddressPrefix 10.0.0.0/16 -Subnet $singleSubnet


$nicName = "SCOM1Nic"
$nic = New-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id


$vm = Add-AzureRmVMNetworkInterface -VM $vmConfig -Id $nic.Id

$sourceUri = "https://scomlabaustraliaeast618.blob.core.windows.net/vhds/rafaelab2-SCOM11-2015-11-08.vhd"

$sourceUri2 = "https://rafaela.blob.core.windows.net/vhds/rafaelab2-SCOM11-disk2.vhd"



$osDisk = New-AzureRmDisk -DiskName "SCOM1OSDisk1" -Disk `
    (New-AzureRmDiskConfig -AccountType StandardLRS  -Location $location -CreateOption Import -SourceUri $sourceUri)     -ResourceGroupName $rgName

$DataDisk1 = New-AzureRmDisk -DiskName "SCOM1DataDisk1" -Disk `
    (New-AzureRmDiskConfig -AccountType StandardLRS  -Location $location -CreateOption Import -SourceUri $sourceUri2)     -ResourceGroupName $rgName



$vm = Set-AzureRmVMOSDisk -VM $vmConfig -ManagedDiskId $osDisk.Id -StorageAccountType StandardLRS -DiskSizeInGB 128 -CreateOption Attach -Windows


$vm = Add-AzureRmVMDataDisk -  "SCOM11" -Name $dataDiskName -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1

#Create the new VM
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm