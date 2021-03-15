$servers = Get-Content -Path C:\Users\**userfolder**\Desktop\VM-List.txt

foreach ($server in $servers){
    Write-Verbose "Working on server $server..." -Verbose
    $vm = $server

    $code = ([ADSI]"WinNT://$vm/Administrators").Remove("WinNT://DIR/**security group to remove**")
    
}

