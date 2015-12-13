cd ..

#ECHO OFF


$name = Read-Host "Quel est votre prénom ?"
$password = Read-Host "Votre mot de passe ? " -AsSecureString

$value = ConvertFrom-SecureString($password)
Write-Host "Votre nom est $name"
Write-Host "Votre mot de passe est : $value "


Pause
