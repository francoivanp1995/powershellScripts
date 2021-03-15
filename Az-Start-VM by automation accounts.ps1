<# The virtual machines must get a tag: ex. "Start-VM" and a valor: ex. "9".
Then the script will check all the tags on the servers and  If the tag are equal to the $date variable, the script will turn on the server
#>


########################################################
# Log in to Azure
########################################################
#Variables.
$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-azAccount `
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


########################################################
# Getting the VMs,Date and Tag
########################################################
#Variables.
$AllVMs = Get-AzVM 
$Date = Get-Date -Format "HH" 
$Tag = "Test-StartVM"


try{

if($AllVMs){

foreach($virtualmachine in $AllVMs){

$RG = $virtualmachine.ResourceGroupName
$VMName = $virtualmachine.Name

Write-Output "Working on virtual Machine: $VMName "

#Checking Tags.
if($virtualmachine.Tags){

    if($virtualmachine.Tags[$Tag]){

        $ValueofTag = $virtualmachine.Tags[$Tag]
        Write-Output "Value is: $ValueofTag"
        Write-Output "Date is: $Date"

           if($ValueofTag -eq $Date){
                #Starting VM.
                Write-Output "Value and Date are equals"
                Write-Output "Starting VM: $VMName"
                Start-AzVM -ResourceGroupName $RG -Name $VMName
               }
        
            }

         }
        
     }

   }


} catch{

if(!$AllVMs){

    $ErrorMsg = "There are not VMs"

    throw $ErrorMsg

    } 
}


