<# Script to reset password from list (csv file)#>

$list = import-csv "$env:userprofile\desktop\userslist.csv"

foreach ($u in $list)
{
    $Generator = ([char[]]([char]33..[char]95) + ([char[]]([char]97..[char]126)) + 0..12 | sort {Get-Random}[0..12] -join '' )
    $Password = ConvertTo-SecureString –String $Generator –AsPlainText –Force
    Get-ADUser -Identity $u.samaccountname | Set-ADAccountPassword -Reset -NewPassword $Password #Reset
    $mail = $u.correo
    $smtpServer = "smtp of the customer"
    #Data del Mail
    $smtpFrom = "our distribution list"
    $smtpTo = $mail
    $messageSubject = "Password Reset"
    $messageBody = "Your account $u has been reset for security reasons. The new password is: $generator"
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer)
    #Envio Correo
    if ($mail -ne $null){
        $smtp.Send($smtpFrom,$smtpTo,$messagesubject,$messagebody)
    }
}