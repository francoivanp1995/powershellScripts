<# Script to get: Server Name, Host, PIC, CPU and total cores from a servers list.#>

$PIC_List = Get-Content -Path 'C:\Users\franco.ivan.paco\Downloads\PICs_List.txt'
$Server_LIst =  Get-Content -Path 'C:\Users\franco.ivan.paco\Downloads\Servers List.txt'

$UserANDpass = Get-Credential
$PICnotconnected = @()
    


#This function is to connect to the vCenters.
foreach($PIC_Name in $PIC_List){
    Write-Verbose "Trying connect to $PIC_Name.." -Verbose        
    $Can = Connect-VIServer $PIC_Name -Credential $UserANDpass -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

        if($Can){

            Write-Verbose "Succesfully connected"-Verbose -ErrorAction SilentlyContinue

            } else{

            Write-Verbose "Not connected"-Verbose -ErrorAction SilentlyContinue
            $PICnotconnected += $PIC_Name
    }
}
$PICnotconnected | Out-GridView 

#Looking for servers.
$VMFound = @()
$NOTFOUND = @()
foreach($ServerName in $Server_LIst){

    Write-Warning "Searching server name $ServerName.."-Verbose
    
    foreach($PIC in $PIC_List){

        Write-Verbose "Checking in $PIC"-Verbose
    
        $obj = Get-VM -Name "$ServerName*" -Server $PIC -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        #Write-Warning "OBJ es $obj.."-Verbose

        if($obj -ne $null){
        
            Write-Host "Server $ServerName found.." -Verbose
            $newobj = New-Object -TypeName psobject
            $newobj | Add-Member -MemberType NoteProperty -Name "Server Name" -Value ($obj).Name
            $newobj | Add-Member -MemberType NoteProperty -Name "Host" -Value ($obj).VMHost.Name
            $newobj | Add-Member -MemberType NoteProperty -Name "PIC" -Value $PIC
            $newobj | Add-Member -MemberType NoteProperty -Name "Physical Processors of the Physical Host (CPU)" -Value ($obj).VMHost.ExtensionData.Hardware.CpuInfo.NumCpuPackages
            $newobj | Add-Member -MemberType NoteProperty -Name "Total Cores" -Value ($obj).VMHost.ExtensionData.Hardware.CpuInfo.NumCpuCores
            $VMFound =+ $newobj 
            
            
            } else {
            $NOTFOUND += $ServerName
            }
        }
        $VMFound | Export-Csv -Path 'C:\Users\franco.ivan.paco\Documents\SearchingPiCandHost\Found-Server-Report.csv' -Append -NoTypeInformation
        $NOTFOUND | Export-Csv -Path 'C:\Users\franco.ivan.paco\Documents\SearchingPiCandHost\ServerNotFound.csv' -Append -NoTypeInformation      
}



