# SIMPLE VARIABLES
##################

$dn_prefix = "DC=" ;
$dn_separator = ",";
$cn_prefix = "CN=" ;
$ou_prefix = "OU=" ;

###################################

# IMPORTANT VARIABLES 
#####################

$X500_LOCAL_DOMAIN = "" ;

# Le domaine contiendra une OU principale [..._objects] pour tous les objets de ce domaine
$DOMAIN_OU_SUFFIX = '_objects';
# Variable qui contiendra le DN complet de l'OU principale
$DOMAIN_OU_DN_FULL = '';
# Variable qui contiendra le DN partiel de l'OU principale (finit avec un separator)
$OU_DN_SUBPATH = '' ;


# Liste des departements de ce domaine (tableau de string)
[string[]]$DPTList  = @();
# Liste des DN FULL departements de ce domaine (tableau de string)
[string[]]$DPTList_DN_FULL  = @();;


#Variables for the DN of the "Managed Services Accounts" dedicated OU
$MSA_DN_SUBPATH = "OU=MSA," ;
$MSA_DN_FULL = '' ;
###################################




cls





##################
##     1.  Configuration de la nomenclature principale

## 1.1  DEMANDER LE NOM DE DOMAIN AU FORMAT X500
# (a partir d'un sous-script)

$TLDList = (& '.\ \getTLDLevels.ps1' ) ;
$TLDLevelsCount = $TLDList.Count - 1 ;

#Write-Host "Domain level count = $TLDLevelsCount";


##################
## 1.2  CONSTRUIRE LE CHEMIN DN DU DOMAINE ET SON OU PRINCIPALE

$loopCount = 0 ;
$DOMAIN_OU_DN_FULL += $dn_prefix ;

$LOWEST_DN_LEVEL= '';

## Construction du STRING DN à partir de l'array

    foreach ($l in $TLDList) { 

        if ($l.Length -gt 0) {
        
            # save the first as the 'local domain' where we operate
            if ($LOWEST_DN_LEVEL.Length -eq 0) {
                $LOWEST_DN_LEVEL = $l;
            }

#            Write-Host "[$l]";
            $DOMAIN_OU_DN_FULL += "$l";

            # rebuild x500 
            $X500_LOCAL_DOMAIN += $l ;

            if ($loopCount -lt $TLDLevelsCount) {
                $DOMAIN_OU_DN_FULL += $dn_separator ;
                $DOMAIN_OU_DN_FULL += $dn_prefix ;
#               Write-Host "$DOMAIN_OU_DN_FULL";

                # rebuild x500 
                $X500_LOCAL_DOMAIN += "." ;

            }           

        
        } # END IF LENGTH
        $loopCount++;

    } # END FOR EACH

## Terminer en ajoutant le nom de l'OU dédiée aux objets du domaine

$OU_DN_SUBPATH = $ou_prefix ;
$OU_DN_SUBPATH += $LOWEST_DN_LEVEL ;
$OU_DN_SUBPATH += $DOMAIN_OU_SUFFIX ;
$OU_DN_SUBPATH += $dn_separator;

$DOMAIN_OU_DN_FULL = $OU_DN_SUBPATH + $DOMAIN_OU_DN_FULL;

Write-Host -f Green "`nMain OU in this domain will have the DN : $DOMAIN_OU_DN_FULL";

####################
## END 1
####################












##################
##     2.  Configuration de la nomenclature des departements

## 2.1  DEMANDER LE NOM DES DEPÄRTEMENTS DE CE DOMAINE
## + CONSTRUCTION DE CHAQUE DN EN MEME TEMPS


    
Write-Host "`n`tVous allez devoir entrer le nom des différents départements." ; 
Write-Host "`tEntrez les un par un et terminez par un nom vide pour cloturer la liste." ;



    $str = '' ;
    $i = 0 ;
    do {
        $str = Read-Host "`nDepartement $i " ;
        if ($str.Length -gt 0) {
            
            $DPTList += "$str";

            $DptTempDN = "$ou_prefix" ;
            $DptTempDN += "$str" ;
            $DptTempDN += "$dn_separator" ;

            $DptTempDN += $DOMAIN_OU_DN_FULL;

            Write-Host -f Green "`n`t$DptTempDN" ;

            $DPTList_DN_FULL += $DptTempDN  ;


            $i++;
        }
    } 
    while ($str.Length -gt 0);

    
    

####################
## END 2
####################


















$DATA_PATH = ".\data" ;

# utiliser ou-h.json pour definir la hierarchie des OU a créer POUR CHAQUE DEPAARTEMENT !
#$OU_FILENAME = "ou.json";
$OU_HIERARCHY_FILENAME = "ou-h.json";

# utiliser 
#$USERS_FILENAME = "users.json" ;
$USERS_FILENAME_SUFFIX = "$X500_LOCAL_DOMAIN.json" ;




##################
##     3.  Creation des OU

## 3.1  SWITCH EN FONCTION DU DOMAINE

if ($LOWEST_DN_LEVEL.Length -eq 0) {

    Write-host "Cannot find the name of the local domain in the DN path."
        -ForegroundColor Red ;

    pause ;
    exit ;
} else { 
  
    Write-host "Gonna search for OU hierarchy in .\data\ou-h.csv" ;

    Write-host "Gonna search for USERS lists by department in :" ;

    foreach ($dpt in $DPTList) {
        Write-Host "`t for DPT [$dpt] `t`t`t--->`t $DATA_PATH\$dpt.$USERS_FILENAME_SUFFIX" ;
    }

    foreach ($dpt in $DPTList) {

        #$OU_DATA = Import-Csv -Delimiter "}" -Path "$DATA_PATH$OU_FILENAME" 
        $USERS_DATA = (Get-content "$DATA_PATH\$dpt.$USERS_FILENAME_SUFFIX") -join "`n" | ConvertFrom-Json ;

        Write-Host "`n`tGot data for DPT [$dpt] from file [$DATA_PATH\$dpt.$USERS_FILENAME_SUFFIX] `n ";
        $USERS_DATA | ft -AutoSize -Wrap | Write-Output ;

    }
}


####################
## END 3
####################










##################
##     4.  Creation des OU

## 4.1  LOAD MODULE AAD
Import-Module ActiveDirectory 

## 4.2  Creation des OU



## 4.3  Creation des USERS