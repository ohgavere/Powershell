<#


.SYNOPSIS
**********************************************************************************
**********************************************************************************
**********************************************************************************
****************************                     *    ****************************
************************           *                      ************************
****************                         *                        ****************
************       *        *                        *                ************
********                                                                  ********
****        Use [Get-help -full ] to show all informations ! TRY IT =)        ****
********                                                                  ********
************     *                     *         *             *      ************
****************               *                                  ****************
************************                  *          *    ************************
****************************      *                   ****************************
**********************************************************************************
**********************************************************************************
**********************************************************************************

This section tells the principal purpose of the command/script.
This one should be clear & shorter.



.DESCRIPTION

This is the description of your command/script.

This is the one where you can speak a bit more about the purposes and/or usage of it.



.PARAMETER name

Informations about the parameter



.EXAMPLE

Set-Example1-Command-Name-In-First-Position -exampleParameter1 value1 -exampleParameter2 value2

-----------------------------------
Then you can explain what it does .
-----------------------------------


.EXAMPLE

Set-Example2-Command-Name-In-First-Position -exampleParameter1 value1 -exampleParameter2 value2

-----------------------------------
Then you can explain what it does .
-----------------------------------



.NOTES

@|AUTHOR::A2BDMB
================

Notes qui ne correspondent pas aux autres section.




.LINK

http://www.get-help/simulate/index.html 

https://www.get-help/simulate/indexs.html




.INPUTS

Here you speak about the inputs.

.OUTPUTS

Here you speak about the outputs.


#>



# This get the basic parameters like '-OutVariable' like any other cmdlet
[CmdletBinding()]

#This configures the parameters given to the cmdLet
Param(        

    #Defines Simple parameter of type 'switch' 
    [switch]$test 
        , #a comma ',' is needed to separate parameters declaration

    #Defines a parameter that :
        # -> you ALWAYS HAVE to set when calling the script
        # -> MUST BE at 1st position
    [Parameter(Mandatory=$True, Position=1)]
    [string]$computerName    ,
	
    #Defines a parameter not mandatory
    [Parameter(Mandatory=$false)]
    [string]$csvPath


)

Write-Host "DEBUG INIT 1 " 

if ($csvPath -ne $null) {
    if ((Test-Path -Path $csvPath) -eq $true) {
        $_DEFAULT_CSV = $csvPath
        Write-Host "Got CSV FILE args ==> [ $_DEFAULT_CSV ] "
    } else {
        Write-Host "$_SPACE_LINE `t The file you specified doesn't seem to exist. Please check. [$csvPath] $_SPACE_LINE " -ForegroundColor Red -BackgroundColor DarkRed ;
    }
}

Write-Host "DEBUG INIT 2 "

if ($args[0] -ne $null) {
#    if ((Test-Path -Path $args[0]) -eq $true) {
    if ((Test-Path -Path $args[0][0]) -eq "-Path") {
        if ((Test-Path -Path $args[0][1]) -eq $true) {
            $_DEFAULT_CSV = $args[0]
            Write-Host "Got CSV FILE args ==> [ $_DEFAULT_CSV ] "
        } else {
            Write-Host "$_SPACE_LINE `t The file you specified doesn't seem to exist. Please check. [$($args[0][0])][$($args[0][1])] $_SPACE_LINE " -ForegroundColor Red -BackgroundColor DarkRed ;
        }
    }
}


