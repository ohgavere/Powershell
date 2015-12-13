$tld1Temp 
$tld2Temp

function askTLDs{

    Write-Host "Vous allez devoir entrer les TLD de votre domaine pour la creation des DN."
    Write-Host "`t Par exemple pour le domain contoso.com : `n TLD 1  =  COM `n TLD 2  = CONTOSO "

    $tld1Temp = Read-Host "Entrez le TLD niveau 1 ? "
    $tld2Temp = Read-Host "Entrez le TLD niveau 2 ? "

    [String[]]$array = $tld1Temp,$tld2Temp;

    
    $tld1Temp,$tld2Temp = $TLDarray
    
    
    Write-Host "sending array : "
    Write-Host " 0 --> " $array[0]
    Write-Host " 1 --> " $array[1]
    

    return  $array


    #Write-Host "sending ARGS : "
    #Write-Host " 0 --> " $TLDarray[0]
    #Write-Host " 1 --> " $TLDarray[1]

    #checkTLDsEntry($TLDarray)

}



[String]$OUContainer

$OURootContainerPath

function buildOURootContainerPath {

    if ($OUContainer -ne $null) {
        $OUchangingPath 
        foreach ($ouLevel in $OUContainer) {
            $OUchangingPath = "OU=$ouLevel,$OUchangingPath"
        }

        $OURootContainerPath =  "$OUchangingPath,OU={user.department},DC=$tld2,DC=$tld1"

        Write-Host "`n`tOUT with DN = $OURootContainerPath `n`n"
    }

    return $OURootContainerPath

}

function askOUContainer {

    $parentContainer = Read-Host "Souhaitez-vous créer les users au sein d'une OU parent principale ? (y/n) `n`t (Cette OU contiendra toutes les OU créées à partir de {user.department} ) `n"
    
    if ($parentContainer -eq "y") {    

        $OUContainer += Read-Host "Entrez le nom de l'OU : " 

        $continue = $true
        
        Write-Host "Souhaitez-vous que cette OU principale soit encapsulée dans d'autres OU existantes ?" 
        
        while ($continue -eq $true) {

            $temp = buildOURootContainerPath
            Write-Host "DN actuel des futurs USERS ==> $temp "
            
            $OUContainerLevelContinue = Read-Host "Ajouter un sous-niveau d'OU ? (y/n)"
            
            if ($OUContainerLevelContinue -eq "y") {

                $OUContainerLevel = Read-Host "Entrez le nom de l'OU : " 

                $OUContainer += $OUContainerLevel

            } else {
                $continue = $false
            }

        }
    
    }
    
    Write-Host "`n`t"

}


#FOR domain dom50.be
    #$tld1 = "BE"
    #$tld1 
    #$tld2 = "DOM50"
    #$tld2

# Add sub OU & add them in right order if needed
    #$OU1
    #$OU2

function checkTLDsEntry {


    Write-Host "received ARGS : "
    Write-Host " 0 --> "`t  $args[0][0] "`t`t OF TYPE --> "  $args[0][0].GetType().Name
    Write-Host " 1 --> "`t  $args[0][1] "`t`t OF TYPE --> "  $args[0][1].GetType().Name
    

    while (
        #($tld1Temp -eq $null) -or ($tld2Temp -eq $null) -or ($tld1Temp.GetType().Name -ne "String") -or ($tld2Temp.GetType().Name -ne "String")  
        ($args[0][0]-eq $null) -or ($args[0][1] -eq $null) -or ($args[0][0].GetType().Name -ne "String") -or ($args[0][1].GetType().Name -ne "String")
    ) {
    
        Write-Host "The data you've given are not correct (null or not type:String). Please retry."
        
        <#
        write-Host "DEBUG:: TLD1 type = "
        Write-Host $args[0][0].GetType().FullName
        write-Host "DEBUG:: TLD2 type = "
        Write-Host $args[0][1].GetType().FullName
        #>

        askTLDs;
        
       }

       $tld1 = $args[0][0]
#       $tld1 = $tld1Temp

       $tld2 = $args[0][1]
#       $tld2 = $tld2Temp

}



# Demander les TLDs
#askTLDs; 
 
# Check les values pour les TLDs
 #checkTLDsEntry; 

 checkTLDsEntry(askTLDs);

 askOUContainer;


# Informations to make a share by department
#    CREATES DIRECTORY
#    CREATES A SCRIPT TO MOUNT VIRTUAL DRIVE AT LOGON
 $dptShareRootFolder          = "\\MS2\SHARES\"             ## WILL ADD DEPARTMENT DIRECTORY INSIDE INSIDE THIS PLACE
 $dptShareScriptRootFolder    = "\\DC1\netlogon\"           ## WILL ADD DEPARTMENT DIRECTORY FOR SCRIPTS INSIDE THIS PLACE
 $dptShareScriptName          = "script_shares.bat"         ## WILL ADD A SCRIPT WITH THIS NAME IN DIRECTORY PREVIOUSLY CREATED
 $dptShareDriveLetter         = "S"                         ## WILL USE THIS LETTER FOR NETWORK DRIVE MAPPING INSIDE SCRIPT
 
 #First part of the command
   #  will be completed for each department
 $dptShareCommandPre          = "net use " + $dptShareDriveLetter + ": " + $dptShareRootFolder

#PATHs to configure
$homeDriveLetter    = "H"
$PathHomeDirectory  = "\\MS1\HOMES\%USERNAME%" 
$PathAccountProfile = "\\MS2\PROFILES\%USERNAME%" 

##########################################
Write-Host "`n`n"
Write-Host "####################################################################################"

    Write-Host "`n`n`t`tFinally start creation for domain DN ==> DC=$tld2,DC=$tld1 `n`n"

    Write-Host "`n `t Each USER account will be placed in this DN inside an OrganizationalUnit"
    Write-Host "`n `t This O.U. will have the name of the user department attribute from CSV file."

    # USER HOME DIR NEWTORK DRIVE
    Write-Host "`n `t Each USER will be have its homeDirectory attribute set to : "
    Write-Host "`n`t`t HOME DIR NETWORK DRIVE LETTER `t : `t $homeDriveLetter"
    Write-Host "`n`t`t HOME DIR NETWORK DRIVE PATH `t : `t $PathHomeDirectory"

    # USER PROFILE DIR
    Write-Host "`n `t Each USER will be have its Profile attribute set to : "
    Write-Host "`n`t`t PROFILE PATH `t : `t $PathAccountProfile"

    # USER DEPARTMENT SHARED FOLDER
    Write-Host "`n `t Each USER will be have its department shared folder set to : "
    Write-Host "`n`t THIS WILL BE CONFIGURED VIA A LOGON SCRIPT CONFIGURED ON USER ACCOUNT !"

    Write-Host "`n`t`t SHARE DIR NETWORK DRIVE LETTER `t : `t $dptShareDriveLetter"
    Write-Host "`n`t`t SHARE DIR NETWORK DRIVE PATH `t : `t $dptShareRootFolder\{user.department}\%USERNAME%"
    Write-Host "`n`t`t SHARE DIR SCRIPT COMMAND`t : `t $dptShareCommandPre{user.department}"
    Write-Host "`n`t`t SHARE DIR SCRIPT LOCATION`t : `t $dptShareScriptRootFolder{user.department}\$dptShareScriptName"



Write-Host "####################################################################################"
Write-Host "`n`n"
##########################################


Read-Host 'Press Enter to continue...    OR    Ctrl+c to END EXECUTION ' | Out-Null
 
Import-Module ActiveDirectory 
$Users = Import-Csv -Delimiter ";" -Path "c:\user.csv"  

foreach ($User in $Users)  
{      

    #Chemin de l'OU où sera placé le USER
    $DistinguishedName = $OURootContainerPath + "OU=" + $user.department + ",DC=" + $tld2 + ",DC=" + $tld1  
    
    #Infos générales du USER
    $Password = "test12345="
    $Detailedname = $User.firstname + " " + $User.lastname
    $UserFirstname = $User.firstname
    $surname = $User.lastname
    $FirstLetterFirstname = $UserFirstname.substring(0,1) 
    $SamAccountName = $FirstLetterFirstname + $User.lastname
    $UPN = $User.upn

    $scriptPath = $dptShareScriptRootFolder + $user.department + "\" + $dptShareScriptName



    #Tester si l'OU existe déjà 
    if([ADSI]::Exists("LDAP://$DistinguishedName")) {                    #Write-Host "Given OU already exists"                }     # Sinon on la crée    else {                    Write-Host "Gonna create OU [$DistinguishedName]"        Write-Host | New-ADOrganizationalUnit -Name $user.department -ProtectedFromAccidentalDeletion $false    }


    Write-Host "-----------------------------"
    Write-Host "  USER DATA BEFORE CREATION"
    Write-Host "-----------------------------"
    Write-Host "FROM CSV"
    Write-Host "  current user :  $User"
    Write-Host "-----------------------------"
    Write-Host " ATTRIBUTES SENT TO New-ADUser"
    Write-Host "-----------------------------"
    #Write-Host " initiales         :   $FirstLetterFirstname "
    Write-Host " -Name            :   $Detailedname  "
    Write-Host " -Surname         :   $surname "
    Write-Host " -SamAccountName  :   $SamAccountName"
    Write-Host " -Path            :   $DistinguishedName "

    Write-Host " -UserPrincipalName : $UPN            "
    Write-Host " -DisplayName     :   $Detailedname   "
    Write-Host " -GivenName       :   $UserFirstname  "
    
    Write-Host " - Password        :   $Password  "
    Write-Host "-----------------------------" 
    Write-Host " -homedrive       :   $homeDriveLetter "
    Write-Host " -homedirectory   :   $PathHomeDirectory "
    Write-Host " -ScriptPath      :   $scriptPath "
    Write-Host " -ProfilePath     :   $PathAccountProfile  "
    Write-Host "-----------------------------"


    Write-Host | New-ADUser -Name $Detailedname -SamAccountName $SamAccountName  -Surname $surname -DisplayName $Detailedname -GivenName $UserFirstname  -homedrive $homeDriveLetter -homedirectory $PathHomeDirectory  -ScriptPath $scriptPath -ProfilePath $PathAccountProfile -UserPrincipalName $UPN -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $false -Path $DistinguishedName  
} 

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "============================="
Write-Host "============================="
Write-Host "============================="
Write-Host ""
Write-Host ""
Write-Host ""

foreach ($dpt in $Users.department) {
    

    Write-Host "CURRENT DEPARTMENT == $dpt"
    



    #CREATE FOLDER TO SHARE
        $dptFolderToCreate = $dptShareRootFolder + $dpt
   
    if ((Test-Path -Path $dptFolderToCreate) -eq $false) {           
    
        Write-Host "Gonny try mkdir :  $dptFolderToCreate"     

        Write-Host | New-Item -Path $dptFolderToCreate -Type directory

            # Prepare commad inside script
        $dptShareCommandFinal = $dptShareCommandPre + $dpt    
    
        Write-Host "Command inserted inside th script :
             $dptShareCommandFinal " 
             
      }

      
      
      
      # Test if script folder in NETLOGON needs to be created
      $dptShareScriptLocation = $dptShareScriptRootFolder + $dpt 

      if ((Test-Path -Path $dptShareScriptLocation) -eq $false) {
            # CREATE IF NEEEDED
         Write-Host | New-Item -Path $dptShareScriptLocation -Type directory

      }




      # Set full script path with name & extension
        $dptShareScriptLocation = $dptShareScriptRootFolder + $dpt + "\" + $dptShareScriptName

        Write-Host "The script will be at :   $dptShareScriptLocation" 

    if ((Test-Path -Path $dptShareScriptLocation) -eq $false) {
        # CREATE THE FILE
        Write-Host "CREATE THE FILE"
        Write-Host | New-Item -Path $dptShareScriptLocation -Type file

        #SEND command to the file
        Write-Host "SEND command to the file"
        Write-Host | Add-Content -Path $dptShareScriptLocation "$dptShareCommandFinal" 



    }
    
}