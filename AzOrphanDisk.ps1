<# 
Version Control

02/08/2019
Added -StartFrom Actualday-90 to the Get-azlog cmdlet to prevent false negatives.
Added Total Log Count as a failcheck to make sure the disk isn't being used at all
The Delete actions are currently commented for both manage and unmanaged disks.

29/07/2019
Modified logic. 
Added Activity Logs to check last modified date instead of creation date for Managed Disks.
Added Tag check to check tags that prevent deleting

#>


$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
#############################################################################
$AZcontext = Get-AzContext
$Sub_name = $AZcontext.subscription.name
$Day90 = (Get-Date).AddDays(-90)
##############################################################
################Get Managed Disk unattached###################
##############################################################
$unattached_managed_disk_object = $null
$unattached_managed_disk_object = @() 
$MVHDS = Get-AzDisk 

#$MVHD = $MVHDS | Where {$_.OwnerId -eq $null}

foreach($disk in $MVHDS){
    Write-Host $disk.Name -ForegroundColor Green


    if($disk.ManagedBy -eq $null){
        #Default state of Unused will be False to prevent deleting disks by default.
        $Unused = $false
        #Disk ID to link it to the Activity Log Record
        $id = $disk.Id
        #Get the last Create or Update Disk activity in the activity log
        $log = get-azlog -ResourceId $id -StartTime $Day90| Where-Object {$_.OperationName.LocalizedValue -eq "Create or Update Disk"} | Select-Object -Last 1
        $logcount = (get-azlog -ResourceId $id -StartTime $Day90).count
        #If there's no Create or Update Disk activity during the last 90 days, the disk has been unattached for longer
        if ($log -eq $null){
                    #TimeStamp will be used for the excel
                    $TimeStamp = "No Create or Update Disk activity in record"
                    #Unused will be set to true to delete the disk
                    $Unused = $true
         }
                    #If a Create or Udpate Disk Activity is still on the Activity Log record, this will retrieve the Time stamp of it and the $Unused will remain as false.
         else {
                    $TimeStamp = $log.EventTimestamp
         }

        $obj = New-Object PSObject

        $obj | Add-Member NoteProperty Name $disk.Name
        $obj | Add-Member NoteProperty Location $disk.Location
        $obj | Add-Member NoteProperty DiskSize $disk.DiskSizeGB
        $obj | Add-Member NoteProperty ResourceGroup $disk.ResourceGroupName
        $obj | Add-Member NoteProperty CreatedOn $disk.TimeCreated
        $obj | Add-Member NoteProperty OS $disk.OsType
        $obj | Add-Member NoteProperty Sku $disk.Sku.Name
        $obj | Add-Member NoteProperty Tier $disk.Sku.Tier
        
         $obj | Add-Member NoteProperty LastModified $TimeStamp
         $obj | add-member -membertype NoteProperty -name "Activity Logs" -Value $logcount

    

        if ($Unused) { 
    
                    Write-Host $obj.name "More than 90 days without Create or Update Disk Activities" 
    
                    if ($disk.Tags.Count -eq 0){
                    $obj | Add-Member NoteProperty Tags -Value "No Tags"
                        $obj | add-member -membertype NoteProperty -name "Without Activity nor tags" -Value "Disk can be deleted"
                        ###UNCOMMENT NEXT LINE TO DELETE DISKS WITHOUT ANY CREATE OR UPDATE DISK ACTIVITY LOGS IN THE PAST 90 DAYS. 
                        ###MAKE SURE THAT'S THE ONLY ACTIVITY YOU WANT TO CHECK. YOU CAN ALSO USE $logcount AS A FAILCHECK THAT'S MORE SECURE 
                        #Remove-AZDisk -ResourceGroupName $obj.ResourceGroup -DiskName $obj.name -Force -Verbose -ErrorAction SilentlyContinue


                    }
                    else{
                    $obj | Add-Member NoteProperty Tags ($disk.Tags.GetEnumerator()  | % { $_.value })
                        $obj | add-member -membertype NoteProperty -name "Without Activity nor tags" -Value "Disk has tags. Review before delete" 
                        
                    }
   
    
        } 
        else {

                            if ($disk.Tags.Count -eq 0){
                    $obj | Add-Member NoteProperty Tags -Value "No Tags"
                        $obj | add-member -membertype NoteProperty -name "Without Activity nor tags" -Value "Disk has been modified or updated during the last 90 days"
                    }
                    else{
                    $obj | Add-Member NoteProperty Tags ($disk.Tags.GetEnumerator()  | % { $_.value })
                        $obj | add-member -membertype NoteProperty -name "Without Activity nor tags" -Value "Disk has tags and has been modified or updated during the last 90 days. Review before delete" 
                    }

         
        }

        $unattached_managed_disk_object += $obj
    }
}

##############################################################
################Get Unmanaged Disk unattached#################
##############################################################

########################################################### 
# Obtaining list of unattached UN-MANAGED disks 
########################################################### 


# Obtaining list of Storage Accounts 
$storageAccounts = Get-AzStorageAccount
 
# List to store details of unattached managed disks 
$unattached_un_managed_disk_object = $null 
$unattached_un_managed_disk_object = @() 
 
 
  foreach ($storageAccount in $storageAccounts) { 
         
        $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName)[0].Value
        $storageAccountContext = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey $storageKey 
        $storageAccountContainer = Get-AzStorageContainer -Context $storageAccountContext 
        $storageAccountTagsCount = $storageaccount.Tags.Count
     
        foreach($storageAccountContainer_iterator in $storageAccountContainer){ 
             
           $blob = Get-AzStorageBlob -Container $storageAccountContainer_iterator.Name -Context $storageAccountContext 
 
                foreach ($blobIterator in $blob) { 
                 
                    if($blobIterator.Name -match ".vhd" -and $blobIterator.ICloudBlob.Properties.LeaseStatus -eq "Unlocked"){ 
                        
                        $unattached_un_managed_disk_object_temp = new-object PSObject  
                        $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "ResourceGroupName" -Value $storageAccount.ResourceGroupName 
                        $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "StorageName" -Value $storageAccount.StorageAccountName 
                        $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "StorageContainerName" -Value $storageAccountContainer_iterator.Name 
                        $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "BlobName" -Value $blobIterator.Name 
                        $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "LeaseStatus" -Value $blobIterator.ICloudBlob.Properties.LeaseStatus 
                        $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "LastModified" -Value $blobIterator.ICloudBlob.Properties.LastModified
                        $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "Disk Uri" -Value $blobIterator.ICloudBlob.Uri.AbsoluteUri
                        
                        
                        # Adding the objects to the final list 

                        if ((Get-date).DayOfYear - $blobIterator.ICloudBlob.Properties.LastModified.DayOfYear -gt 90) {
                        Write-Host $unattached_un_managed_disk_object_temp.BlobName "More than 90 days without modification"

       
                        
                            if ($storageAccountTagsCount -eq 0)
                            {$unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty Tags -Value "No Tags"
                            $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "Can be deleted?" -Value "Disk Without Activities nor Tags. Can be deleted"
                            ###UNCOMMENT NEXT LINE TO DELETE DISKS WITHOUT ANY MODIFICATIONS IN THE LAST 90 DAYS. 
                            #$osDiskStorageAcct | Remove-AzStorageBlo -Container $osDiskContainerName -Blob $osDiskUri.Split('/')[-1] -ErrorAction SilentlyContinue

                            # Unmanaged disk deletion process, +90 Days
                            #$blobIterator | Remove-AzStorageBlo -Force
                            #$osDiskUri = $unattached_un_managed_disk_object_temp.'Disk Uri'
                            #$osDiskContainerName = $osDiskUri.Split("/")[-2]
                            #$osDiskStorageAcct = et-AzStorageAccount | where { $_.StorageAccountName -eq $osDiskUri.Split('/')[2].Split('.')[0] }
                            }
                            else
                            {
                            $unattached_un_managed_disk_object_temp | Add-Member NoteProperty Tags ($disk.Tags.GetEnumerator()  | % { $_.value })
                            $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "Can be deleted?" -Value "Disk has Tags. Review before deleting"
                            }


                        }

                        else{

                         if ($storageAccountTagsCount -eq 0)
                            {$unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty Tags -Value "No Tags"
                            $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "Can be deleted?" -Value "Disk has been modified in the past 90 days. Review before deleting"
                           
                            }
                            else
                            {
                            $unattached_un_managed_disk_object_temp | Add-Member NoteProperty Tags ($disk.Tags.GetEnumerator()  | % { $_.value })
                            $unattached_un_managed_disk_object_temp | add-member -membertype NoteProperty -name "Can be deleted?" -Value "Disk has Tags and has been modified in the past 90 days. Review before deleting"
                            }
                        }

                        $unattached_un_managed_disk_object += $unattached_un_managed_disk_object_temp 
    
                  } 
                 
             } 

        } 
 
    } 


$unattached_un_managed_disk_object | Export-Csv -Path $env:USERPROFILE\desktop\unattached_un_managed_disk_$Sub_name.csv -NoTypeInformation -Force

$unattached_managed_disk_object | Export-Csv -Path $env:USERPROFILE\desktop\unattached_managed_disk_$Sub_name.csv -NoTypeInformation -Force

##############################################################################
$SMTPCredentials = Get-AutomationPSCredential -Name 'Sendgrid_credential'
$Username = $SMTPCredentials.UserName
$Password = $SMTPCredentials.Password
$credential = New-Object System.Management.Automation.PSCredential $Username, $Password

$SMTPServer = "smtp.sendgrid.net"

$EmailFrom = ""

$EmailTo =  @("")
$Subject = "Unattached Disk Report $sub_name"

$Body = " "

Send-MailMessage -smtpServer $SMTPServer -Credential $credential -Usessl -Port 587 -from $EmailFrom -to $EmailTo -subject $Subject -Body $Body -BodyAsHtml -attachment "$env:USERPROFILE\desktop\unattached_un_managed_disk_$Sub_name.csv","$env:USERPROFILE\desktop\unattached_managed_disk_$Sub_name.csv" -verbose
Write-Output "Email sent succesfully."