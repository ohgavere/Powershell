Import-Module ActiveDirectory 
$Users = Import-Csv -Delimiter ";" -Path "c:\users.csv"  
foreach ($User in $Users)  
{  
    $OU = "OU="+$user.department+",ou=users,DC=DOM40,DC=com"  
    $Password = "test12345="
    $Detailedname = $User.firstname + " " + $User.name 
    $UserFirstname = $User.Firstname 
    $FirstLetterFirstname = $UserFirstname.substring(0,1) 
    $UPN = $User.upn
    New-ADUser -Name $Detailedname -SamAccountName $UPN -UserPrincipalName $UPN -DisplayName $Detailedname -GivenName $user.firstname -Surname $user.name -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $false -Path $OU  
} 