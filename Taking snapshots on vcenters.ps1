# Getting modules to check Power.CLi
$Module = Get-Module -Name VMware.PowerCLI
if($Module -eq $null){

 Write-Host "Vmware Powercli is not installed on your workstation. Installing PowerCli .."-Verbose
 $o = Import-Module VMware.PowerCLI -ErrorAction SilentlyContinue
 $o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false  
 Write-Verbose "Sucessfully installed" -Verbose
}


#Variables.
#Ex: <xxx>
$Credential = Get-Credential

#Example: contoso.example.com
$PICList = ("List of PICs)


#Server list //Create a txt file with the servers name.
$ServerList = "$env:USERPROFILE\Documents\List.txt"

$array_successfully = @()
$snapshotName = Read-Host "Name for the new snapshot (If the string contains spaces, write it in quotes)" -ErrorAction SilentlyContinue
$snapshotDescription = Read-Host "Provide a description of the new snapshot (If the string contains spaces, write it in quotes)" -Verbose -ErrorAction SilentlyContinue


function lookingforserver($name){
    $virtualmachinename_input = "$($name)*"
    $servername_output = $null
    $Allvms = Get-VM
    $Count = $Allvms.Count
    $indice = 0
    while(($indice -lt $Count) -and ($virtualmachinename_input -ne $Allvms[$indice].Name)){
        $indice++
    }

    if($indice -eq $Count){
        $servername_output = $null
    } else {
        $servername_output = $Allvms[$indice].Name
    }
    return $servername_output
}


foreach($Pic in $PICList){

Write-Verbose "Working on PIC: $Pic"-Verbose
Connect-VIServer -Server $Pic -Credential $Credential -ErrorAction SilentlyContinue 

foreach($server in $ServerList){
    Write-Host "Working on $server"-Verbose
    $found = lookingforserver($server)

    if($found){
       
        $Snap = New-Snapshot -VM $found -Name $snapshotName -Description $snapshotDescription -Memory $false 

        if($Snap){
            Write-Verbose "Snapshot has been taken successfully"-Verbose
            $array_successfully += $found
        }

    }

    } 


}

$array_successfully | Out-File $env:USERPROFILE\Documents\Snaps.txt -Append

