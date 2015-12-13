Function CreateUsersFromCsv
{


#[CmdletBinding()]
Param(
  #[Parameter(Mandatory=$True,Position=1)]
   #[string]$computerName,
	
   [Parameter(Mandatory=$false)]
   [string]$csvPath,

   [Parameter(Mandatory=$false, de )]
   [bool]$makeOU,

   [switch]$test
)
Process {

    Write-Host "================================================="
    Write-Host "===   First Checks before running"
    Write-Host "================================================="

    if ($makeOU -eq $null) { $makeOU = $false }
    Write-Host "::makeOU --`t--`t-- [$makeOU]"
    
}




<# ************************************************* #>
<# *** DEFAULT VARIABLES ************************************************************** #>
<# ************************************************* #>

#DEFAULT CSV FILE PATH & NAME
$_DEFAULT_CSV = "c:\user.csv" 

#DEFAULT makeOU value
$_DEFAULT_makeOU = $true


$_SPACE_LINE = "`n==================================================================================================`n"




<# ************************************************* #>
<# *** WORKED VARIABLES ************************************************************** #>
<# ************************************************* #>



#FOR domain dom50.be
$tld1 = "BE"
$tld2 = "DOM50"
# Add sub OU & add them in right order if needed
#$OU1
#$OU2



# Informations to make a share by department
#    CREATES DIRECTORY
#    CREATES A SCRIPT TO MOUNT VIRTUAL DRIVE AT LOGON
 $dptShareRootFolder          = "\\MS2\SHARES\"
 $dptShareScriptRootFolder    = "\\DC1\netlogon\"
 $dptShareScriptName          = "script_shares.bat"
 $dptShareDriveLetter         = "S"
 
 #First part of the command
   #  will be completed for each department
 $dptShareCommandPre          = "net use " + $dptShareDriveLetter + ": " + $dptShareRootFolder




<# ************************************************* #>
<# *** CHECK INIT PARAMS ************************************************************** #>
<# ************************************************* #>

if ($csvPath -ne $null) {
    
    if ((Test-Path -Path $csvPath) -eq $true) {
        # NOT FOR USE IT BUT TO REMOVE ANY POSSIBLE CONFLICT
        $_DEFAULT_CSV = $csvPath
        Write-Host "Got CSV FILE args ==> [ $_DEFAULT_CSV ] "

    } else {
        Write-Host "$_SPACE_LINE `t The file you specified doesn't seem to exist. Please check. [$csvPath] $_SPACE_LINE " -ForegroundColor Red -BackgroundColor DarkRed ;
    }

}

Write-Host "Will load CSV file at $_DEFAULT_CSV" 





Import-Module ActiveDirectory 
$Users = Import-Csv -Delimiter ";" -Path $_DEFAULT_CSV






foreach ($User in $Users)  {      

    $DistinguishedName = "OU=" + $user.department + ",DC=" + $tld2 + ",DC=" + $tld1  
    $Password = "test12345="
    $Detailedname = $User.firstname + " " + $User.lastname
    $UserFirstname = $User.firstname
    $surname = $User.lastname
    $FirstLetterFirstname = $UserFirstname.substring(0,1) 
    $SamAccountName = $FirstLetterFirstname + $User.lastname
    $UPN = $User.upn

    $homeDriveLetter    = "H"
    $PathHomeDirectory  = "\\MS1\HOMES\%USERNAME%" 
    $PathAccountProfile = "\\MS2\PROFILES\%USERNAME%" 
    $scriptPath = $dptShareScriptRootFolder + $user.department + "\" + $dptShareScriptName


    echo "-----------------------------"
    echo "  USER DATA BEFORE CREATION"
    echo "-----------------------------"
    echo "FROM CSV"
    echo "  current user :  $User"
    echo "-----------------------------"
    echo " ATTRIBUTES SENT TO New-ADUser"
    echo "-----------------------------"
    #echo " initiales         :   $FirstLetterFirstname "
    echo " -Name            :   $Detailedname  "
    echo " -Surname         :   $surname "
    echo " -SamAccountName  :   $SamAccountName"
    echo " -Path            :   $DistinguishedName "

    echo " -UserPrincipalName : $UPN            "
    echo " -DisplayName     :   $Detailedname   "
    echo " -GivenName       :   $UserFirstname  "
    
    echo " - Password        :   $Password  "
    echo "-----------------------------" 
    echo " -homedrive       :   $homeDriveLetter "
    echo " -homedirectory   :   $PathHomeDirectory "
    echo " -ScriptPath      :   $scriptPath "
    echo " -ProcsvPath     :   $PathAccountProfile  "
    echo "-----------------------------"


    New-ADUser -Name $Detailedname -SamAccountName $SamAccountName  -Surname $surname -DisplayName $Detailedname -GivenName $UserFirstname  -homedrive $homeDriveLetter -homedirectory $PathHomeDirectory  -ScriptPath $scriptPath -ProcsvPath $PathAccountProfile -UserPrincipalName $UPN -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $false -Path $DistinguishedName  
} 

echo ""
echo ""
echo ""
echo "============================="
echo "============================="
echo "============================="
echo ""
echo ""
echo ""


$arrayDpt = [System.Collections.ArrayList]@()

#= $(
foreach ($dpt in $Users.department) {  
    

    Write-Host "`n`t`t Debug::   Got value [$dpt]  eq? -> " + ($arrayDpt -eq $dpt)

    $arrayDpt.add($dpt)

    #Write-Host "`n`t`t Debug::   Got value [$dpt]"



} 
#) | sort | Get-Unique -AsString ;



Write-Host "Count 1 (initial data ) == " $Users.department.Count ;
Write-Host "Count 2 (resultArray before) == " $arrayDpt.Count ;
#$arrayDpt = $arrayDpt | Sort-Object -Unique # works too
$arrayDpt = $arrayDpt | Sort-Object | Get-Unique -AsString

Write-Host "Last Count (resultArray after) == " $arrayDpt.Count ;



#foreach ($dpt in $arrayDpt) {   Write-Host "`n`n`t DEBUG2::: Got [$dpt]"}


foreach ($dpt in $arrayDpt) {
    


    #$dpt = $arrayDpt.

    echo "`nCURRENT DEPARTMENT == $dpt"
    




    #CREATE FOLDER TO SHARE
        $dptFolderToCreate = $dptShareRootFolder + $dpt
   
    if ((Test-Path -Path $dptFolderToCreate) -eq $false) {           
    
        echo "Gonny try mkdir :  $dptFolderToCreate"     

        New-Item -Path $dptFolderToCreate -Type directory

            # Prepare commad inside script
        $dptShareCommandFinal = $dptShareCommandPre + $dpt    
    
        echo "Command inserted inside th script :
             $dptShareCommandFinal " 
             
      }



      
      
      
      # Test if script folder in NETLOGON needs to be created
      $dptShareScriptLocation = $dptShareScriptRootFolder + $dpt 

      if ((Test-Path -Path $dptShareScriptLocation) -eq $false) {
            # CREATE IF NEEEDED
         New-Item -Path $dptShareScriptLocation -Type directory

      }






      # Set full script path with name & extension
        $dptShareScriptLocation = $dptShareScriptRootFolder + $dpt + "\" + $dptShareScriptName

        echo "The script will be at :   $dptShareScriptLocation" 


    if ((Test-Path -Path $dptShareScriptLocation) -eq $false) {

        # CREATE THE FILE
        echo "CREATE THE FILE"
        New-Item -Path $dptShareScriptLocation -Type file

        #SEND command to the file
        echo "SEND command to the file"
        Add-Content -Path $dptShareScriptLocation "$dptShareCommandFinal" 



    }
    
}


}