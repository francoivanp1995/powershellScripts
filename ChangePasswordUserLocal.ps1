<# Script to change/reset a local user password on the servers. 
Note: You must create a scheduled task from Group Policy Management.
#>

$localuser = [ADSI]"WinNT://$env:COMPUTERNAME/<User>" # Replace "user" for the user to change/reset the password
if($localuser.properties -eq $null){
    Write-Host "$localuser does not exist on $ENV:COMPUTERNAME" -ForegroundColor red -BackgroundColor black >> C:\logadminlocal.txt 
        $user = "<user"
        $objOU = [ADSI]"WinNT://$env:COMPUTERNAME"
        $objuser = $objOU.create("User", $user)
        $u = $objuser.setpassword("<password>") #create a password generator function
        $objuser.setinfo()
    Write-Host "User Created as..." $user -ForegroundColor Green -BackgroundColor Black
}else{
    Write-Host "$localuser exists on $ENV:COMPUTERNAME" -ForegroundColor yellow -BackgroundColor black  >> C:\logadminlocal.txt 
        $localuser.setpassword("<>") #create a password generator function
        $localuser.setinfo()
        $DomainUser= "$user"
    write-host "Password has been changed" -ForegroundColor Green
#([ADSI]"WinNT://$env:COMPUTERNAME/$LocalGroup,group").Add("WinNT://$env:COMPUTERNAME/$DomainUser") 
}
Clear-Host
 