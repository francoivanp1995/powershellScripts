$DestResourceGroupName = "RG"
$DestVirtualNetworkName = "Vnet"
$DestLocationName = "Location"
$DestVirtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $DestResourceGroupName -Name $DestVirtualNetworkName
$MyNewVM1Name = "VM name"
$PublicIPName = "Public IP for the vm"
$NicName = "NIC for the vm"

$PublicIp = New-AzPublicIpAddress -Name $PublicIPName -ResourceGroupName $DestResourceGroupName -Location $DestLocationName -AllocationMethod Dynamic
$NetworkInterface = New-AzNetworkInterface -ResourceGroupName $DestResourceGroupName -Name $NicName -Location $DestLocationName -SubnetId $DestvirtualNetwork.Subnets[1].Id -PublicIpAddressId $PublicIp.Id
$DestVMOSVhd = "https://"+$DestStorageAccountName+".blob.core.windows.net/"+$DestStorageContainerName+"/"+$MyNewVM1Name+".vhd"

$DestVmConfig = New-AzVMConfig -VMName $MyNewVM1Name -VMSize "Standard_D2_v2"
$DestVmConfig = Set-AzVMOSDisk -VM $DestVmConfig -Name $MyNewVM1Name -VhdUri $DestVMOSVhd -CreateOption Attach -Windows # or -Linux
$DestVmConfig = Add-AzVMNetworkInterface -VM $DestVmConfig -Id $NetworkInterface.Id

$NewVm = New-AzVM -VM $DestVMConfig -Location $DestLocationName -ResourceGroupName $DestResourceGroupName