Import-Module ActiveDirectory

# Se define la fecha límite de LastLogonDate colocando la cantidad de dias en la variable Days
$Date = Get-Date -UFormat %d%m%y
$DaysInactive = 35
$time = (Get-Date).Adddays(-($DaysInactive))


# Filtra las maquinas a deshabilitar
$listaDeshabilitar = @()
$preListaDeshabilitar = Get-ADComputer -Filter {(OperatingSystem -notlike "*windows*server*") -and (LastLogonTimeStamp -lt $time) -and (Enabled -eq "True")} -Properties LastLogonTimeStamp | Select Name, lastLogonDate, DistinguishedName
$preListaDeshabilitar | ForEach-Object {
    if (-not (Test-Connection -Computername $_.Name -BufferSize 16 -Count 1 -Quiet)) {
        $listaDeshabilitar += $_.Name
        #Write-Host $_.name maquina apagada o inexistente
        # Deshabilita la maquina
        Disable-ADAccount -Identity $_.DistinguishedName
        
        #Write-Host $_.name deshabilitada
    } 
} 

# Exporta a CSV la lista generada
$path = "C:\Script Task Scheduled\Remove Old Computers\Computadoras_Deshabilitadas_" + $Date + ".txt"
$listaDeshabilitar | out-file $path -Append

# Se define la fecha límite de LastLogonDate colocando la cantidad de dias en la variable Days
$DaysInactive = 45
$time = (Get-Date).Adddays(-($DaysInactive))

# Filtra las maquinas a eliminar
$listaEliminar = @()
$prelistaEliminar = Get-ADComputer -Filter {(OperatingSystem -notlike "*windows*server*") -and (LastLogonTimeStamp -lt $time) -and (Enabled -eq "False")} -Properties LastLogonTimeStamp | Select Name, lastLogonDate, DistinguishedName
$prelistaEliminar | ForEach-Object {
    if (-not (Test-Connection -Computername $_.Name -BufferSize 16 -Count 1 -Quiet)) {
        $listaEliminar += $_.Name
        #Write-Host $_.name maquina apagada o inexistente
        # Elimina la maquina
        Remove-ADObject $_.DistinguishedName -Recursive -IncludeDeletedObjects -Confirm:$false -Verbose
        #Write-Host $_.name eliminada
    }
}

# Exporta a CSV la lista generada
$path = "C:\Script Task Scheduled\Remove Old Computers\Computadoras_Borradas_" + $Date + ".txt"
$listaEliminar | out-file $path -Append

# Se define la fecha límite de LastLogonDate colocando la cantidad de dias en la variable Days
$DaysInactive = 1
$time = (Get-Date).Adddays(-($DaysInactive))

# Exporta a CSV las maquinas y las habilita
$path = "C:\Script Task Scheduled\Remove Old Computers\Computadoras_Habilitadas_" + $Date + ".csv"
Get-ADComputer -Filter {(OperatingSystem -notlike "*windows*server*") -and (LastLogonTimeStamp -gt $time) -and (Enabled -eq "False")} -Properties LastLogonTimeStamp | Select Name, lastLogonDate, DistinguishedName | Export-Csv $path -NoTypeInformation | Enable-ADAccount