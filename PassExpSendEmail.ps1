function Exp-Acc-Mail{
    param(
        [Parameter(mandatory=$true)]$days,
        $mail,
        $Account
    )
    
    $smtpServer = "smtp server"
    #Data del Mail
    $smtpFrom = "our distrution list"
    $smtpTo = $mail
    $messageSubject = "Account will expire"
    $messageBody = "Your account $Account will expire on $days days. Please contact the administrator to avoid this. Thanks"
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    #Envio Correo
    if ($mail -ne $null){
        $smtp.Send($smtpFrom,$smtpTo,$messagesubject,$messagebody)
    }
}

function Exp-Pass-Mail{
    param(
        [Parameter(mandatory=$true)]$days,
        $mail,
        $Account
    )
        $smtpServer = "smtp server"
        #Data del Mail
        $smtpFrom = "our distrution list"
        $smtpTo = "$mail"
        $messageSubject = "Password will expire"
        $messageBody = "The password of your account $Account will expire on $days days. Please, change it to avoid locking. Thanks!"
        $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    if($mail -ne $null){
        #Envio Correo
        $smtp.Send($smtpFrom,$smtpTo,$messagesubject,$messagebody)
    }
}

$tdy = Get-Date

$passExpiryDate = $passExpiryDate.Date
$30DFN = $tdy.AddDays(30).Date
$20DFN = $tdy.AddDays(20).Date
$10DFN = $tdy.AddDays(10).Date
$5DFN = $tdy.AddDays(5).Date
$3DFN = $tdy.AddDays(3).Date
$1DFN = $tdy.AddDays(1).Date

$g = Get-ADGroupMember -Identity "group to check" #Cargar grupo/s que se analizaran
$h = Get-ADGroupMember -Identity "group to check"
$i = Get-ADGroupMember -Identity "group to check"

$g += $h
$g += $i

foreach($u in $g){
    Write-Host "Checking $Account"
    $usuario = Get-ADUser -Identity $u -Properties accountexpirationdate,msDS-UserPasswordExpiryTimeComputed,mail
    $passExpiryDate = [datetime]::FromFileTime($usuario.'msDS-UserPasswordExpiryTimeComputed')
    $accExpiration = $usuario.AccountExpirationDate
    $mail = $usuario.mail
    $Account = $usuario.SamAccountName
    

    if(($passExpiryDate -eq $30DFN)){Exp-Pass-Mail -days 30 -mail $mail -Account $Account
    }elseif(($passExpiryDate -eq $20DFN)){Exp-Pass-Mail -days 20 -mail $mail -Account $Account
    }elseif(($passExpiryDate -eq $10DFN)){Exp-Pass-Mail -days 10 -mail $mail -Account $Account
    }elseif(($passExpiryDate -eq $5DFN)){Exp-Pass-Mail -days 5 -mail $mail -Account $Account
    }elseif(($passExpiryDate -eq $1DFN)){Exp-Pass-Mail -days 1 -mail $mail -Account $Account
    }else{
        Write-Host "n/a"
    }

    if(($accExpiration -eq $30DFN)){Exp-Acc-Mail -days 30 -mail $mail -Account $Account
    }elseif(($accExpiration -eq $20DFN)){Exp-Acc-Mail -days 20 -mail $mail -Account $Account
    }elseif(($accExpiration -eq $10DFN)){Exp-Acc-Mail -days 10 -mail $mail -Account $Account
    }elseif(($accExpiration -eq $5DFN)){Exp-Acc-Mail -days 5 -mail $mail -Account $Account
    }elseif(($accExpiration -eq $1DFN)){Exp-Acc-Mail -days 1 -mail $mail -Account $Account
    }else{
        Write-Host "n/a"
    }

}