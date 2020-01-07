$resource_group = "resource1"
$vm_name = "sahana"
$local_dir = "/Users/ssrivats/Desktop/Azure/Automation/drop_schema"
$storage_dir = "https://sahanastorageaccount.blob.core.windows.net/sqlpowershellautomation"
$script1 = "blob.ps1"
$script2 = "script_nondataset.ps1"


##to copy files from local to azure blob storage
./azcopy copy $local_dir $storage_dir --recursive

##to invoke vm and download files from blob storage to vm
#az vm run-command invoke --command-id RunPowerShellScript --name $vm_name -g $resource_group --scripts '$script1'
Invoke-AzVMRunCommand -ResourceGroupName $resource_group -VMName $vm_name -CommandId 'RunPowerShellScript' -ScriptPath $script1

##to call the script on azure VM which will connect to database and run the copied files (DDL's)
#az vm run-command invoke --command-id RunPowerShellScript --name $vm_name -g $resource_group --scripts '$script2'
Invoke-AzVMRunCommand -ResourceGroupName $resource_group -VMName $vm_name -CommandId 'RunPowerShellScript' -ScriptPath $script2
