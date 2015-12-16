function getTLDs ($domainName) {

#$computed = [System.Collections.ArrayList]@()
$computed ;

    [string]$DNcopy = $domainName ;

    $computed = ($DNcopy.Trim()).Split('.') ;

    $commaCount = $computed.Count ;

#    Write-Host "`n RESULT == $commaCount `|`| First array try ==> `n" ;
    
#    foreach ($l in $computed) { 
#        Write-Host "[DN=$l]" ; 
#    } 
    
#    Write-Host "`n" ;
    
return $computed ;

}


$received = Read-Host "Entrez le nom complet de votre (sous-)domaine au format X500 " ;

$tldArray = getTLDs($received);

#Write-Host $tldArray.ToString(); ;

return $tldArray ;