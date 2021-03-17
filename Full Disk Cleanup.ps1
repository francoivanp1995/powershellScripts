#Disk-Cleanup

#Statics
$server = hostname
$DaysToDelete = 7

## Deletes the contents of windows software distribution. 
Get-ChildItem "\\$server\C$\Users\*\Windows\SoftwareDistribution\download\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue
## The Contents of Windows SoftwareDistribution have been removed successfully!

## Deletes the contents of the Windows Temp folder. 
Get-ChildItem "\\$server\C$\Users\*\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue
## The Contents of Windows Temp have been removed successfully! 

## Deletes the contents of the Windows Temp folder. 
Get-ChildItem "\\$server\C$\Users\*\Windows\Temp\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue
## The Contents of Windows Temp have been removed successfully! 

## Delets all files and folders in CCM Cache.  
Get-ChildItem "\\$server\C$\Users\*\Windows\CCM\Cache\ccmcache\*" -Recurse -Force -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The contents of CCM Cache 1 have been removed successfully! 

## Delets all files and folders in CCM Cache 2.  
Get-ChildItem "\\$server\C$\Users\*\Windows\ccmcache\*" -Recurse -Force -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The contents of CCM Cache 2 have been removed successfully! 

## Delets all files and folders in user's Temp folder.  
Get-ChildItem "\\$server\C$\Users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue | remove-item -force -Verbose -recurse -ErrorAction SilentlyContinue 
## The contents of Temp User's folder have been removed successfully! 


## Removes all files and folders in user's Temporary Internet Files older then $DaysToDelete
Get-ChildItem "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -Verbose -ErrorAction SilentlyContinue | Where-Object {($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete))} | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue -Verbose

## Removes *.log from C:\windows\CBS
if(Test-Path "\\$server\C$\Users\*\Windows\logs\CBS\"){
    Get-ChildItem "\\$server\C$\Users\*\Windows\logs\CBS\*.log" -Recurse -Force -ErrorAction SilentlyContinue |
        remove-item -force -recurse -ErrorAction SilentlyContinue }

## Cleans IIS Logs older then $DaysToDelete
if (Test-Path "\\$server\C$\Users\*\inetpub\logs\LogFiles\*") {
Get-ChildItem "\\$server\C$\Users\*\inetpub\logs\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue |
Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-7)) } | Remove-Item -Force -Verbose -Recurse -ErrorAction SilentlyContinue }

## Removes C:\Config.Msi
if (test-path "\\$server\C$\Users\*\Config.Msi"){
        remove-item -Path "\\$server\C$\Users\*\Config.Msi" -force -recurse -Verbose -ErrorAction SilentlyContinue}

 ## Removes c:\PerfLogs
    if (test-path c:\PerfLogs){
        remove-item -Path c:\PerfLogs -force -recurse -Verbose -ErrorAction SilentlyContinue
    } 

 ## Removes $env:windir\memory.dmp
    if (test-path $env:windir\memory.dmp){
        remove-item $env:windir\memory.dmp -force -Verbose -ErrorAction SilentlyContinue
    }

    ## Removes Windows Error Reporting files
    if (test-path C:\ProgramData\Microsoft\Windows\WER){
        Get-ChildItem -Path C:\ProgramData\Microsoft\Windows\WER -Recurse | Remove-Item -force -recurse -Verbose -ErrorAction SilentlyContinue
        } 

    ## Removes System and User Temp Files - lots of access denied will occur.
    ## Cleans up c:\windows\temp
    if (Test-Path $env:windir\Temp\) {
        Remove-Item -Path "$env:windir\Temp\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up minidump
    if (Test-Path $env:windir\minidump\) {
        Remove-Item -Path "$env:windir\minidump\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up prefetch
    if (Test-Path $env:windir\Prefetch\) {
        Remove-Item -Path "$env:windir\Prefetch\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up all users windows error reporting
    if (Test-Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\WER\") {
        Remove-Item -Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\WER\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up users temporary internet files
    if (Test-Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\") {
        Remove-Item -Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up Internet Explorer cache
    if (Test-Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\") {
        Remove-Item -Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up Internet Explorer cache
    if (Test-Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\") {
        Remove-Item -Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up Internet Explorer download history
    if (Test-Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\") {
        Remove-Item -Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up Internet Cache
    if (Test-Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\INetCache\") {
        Remove-Item -Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\INetCache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up Internet Cookies
    if (Test-Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\INetCookies\") {
        Remove-Item -Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Windows\INetCookies\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    } 

    ## Cleans up terminal server cache
    if (Test-Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\") {
        Remove-Item -Path "\\$server\C$\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\*" -Force -Recurse -Verbose -ErrorAction SilentlyContinue
    }
   
    ## Removes the hidden recycling bin.
    if (Test-path "\\$server\C$\Users\*\$Recycle.Bin"){
        Remove-Item "\\$server\C$\Users\*\$Recycle.Bin" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }