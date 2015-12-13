

#[CmdletBinding()]
Param(
  #[Parameter(Mandatory=$True,Position=1)]
   #[string]$computerName,
	
   [Parameter(Mandatory=$false)]
   [string]$csvPath,

   [Parameter(Mandatory=$false)]
   [bool]$makeOU,

   [switch]$test
)


<# ************************************************* #>
<# *** DEFAULT VARIABLES ************************************************************** #>
<# ************************************************* #>

$_SPACE_LINE = "`n==================================================================================================`n"

$_DEFAULT_CSV = "c:\user.csv"
$_DEFAULT_makeOU = $false


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
<# *** CHECK PARAMS ************************************************************** #>
<# ************************************************* #>

Write-Host "================================================="
Write-Host "===   First Checks before running"
Write-Host "================================================="

#if ($csvPath -eq $null) { $csvPath  = $_DEFAULT_CSV }
if ($csvPath -ne $null) {
    if ((Test-Path -Path $csvPath) -eq $true) {
        # NOT FOR USE IT BUT TO REMOVE ANY POSSIBLE CONFLICT
        $_DEFAULT_CSV = $csvPath
        Write-Host "Got CSV FILE args ==> [ $_DEFAULT_CSV ] "

    } else {
        Write-Host "$_SPACE_LINE `t The file you specified doesn't seem to exist. Please check. [$csvPath] $_SPACE_LINE " -ForegroundColor Red -BackgroundColor DarkRed ;
    }

}
if ($makeOU -eq $null) { $makeOU   = $_DEFAULT_makeOU } 
    else { $_DEFAULT_makeOU = $makeOU }

Write-Host "::csvPath `t--`t`t-- [$csvPath]"
Write-Host "::makeOU  `t--`t`t-- [$makeOU]"

Write-Host "================================================="
    




<# ************************************************* #>
<# *** PRE-LOADS ************************************************************** #>
<# ************************************************* #>
Write-Host "================================================="
Write-Host "===   Starting loading "
Write-Host "================================================="

Write-Host "=======   Loading AD module ======="
Import-Module ActiveDirectory 

Write-Host "=======   Loading CSV file ======="
$Users = Import-Csv -Delimiter ";" -Path $_DEFAULT_CSV
$arrayDpt = [System.Collections.ArrayList]@()

foreach ($dpt in $Users.department) {  
    
    #Write-Host "`n`t`t Debug::   Got value [$dpt]  eq? -> " + ($arrayDpt -eq $dpt)

    $arrayDpt.add($dpt)

    #Write-Host "`n`t`t Debug::   Got value [$dpt]"

} 

#Write-Host "Initial dpt copunt check 1 == " $Users.department.Count ;
#Write-Host "Initial dpt copunt check 2 (before get-unique) == " $arrayDpt.Count ;
#$arrayDpt = $arrayDpt | Sort-Object -Unique # works too
$arrayDpt = $arrayDpt | Sort-Object | Get-Unique -AsString
#Write-Host "Last Count (after get-unique) == " $arrayDpt.Count ;





Write-Host "`t`t`t Got [ $Users.Count ] user(s) from CSV"
Write-Host "`t`t`t`t with [ $arrayDpt.Count ] different department(s). "

















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
Write-Host $_SPACE_LINE
echo ""
echo ""
echo ""


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

