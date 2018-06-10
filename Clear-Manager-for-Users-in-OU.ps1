#Requires -Version 2.0

<#
.SYNOPSIS
   Clean Manager attribute for Users in specific OU

.DESCRIPTION
   This script cleaning user attribute:manager for all users in specific Organizational Unit (OU).
   (Set for AD user attribute manager value $null)
   Needed rights in AD for edit this attribute.
   For example - Domain Admins
   
   Section Initialisations
   To set default value for parameter OU in line:
      [string]$OU =
   set value
      [string]$OU = "OU=Users,OU=Disabled Accounts,DC=myDomain,DC=local"

   Set default values before run script without parameters.

   Script can be useful for disabled users accounts.

.PARAMETER OU
   Uses to specify Organizational Unit (OU) with users.
   If OU not specified, script uses defaul value
   See parameter defaul value in line:
      [string]$OU =
   Example to use: -OU "OU=Users,OU=Disabled Accounts,DC=myDomain,DC=local"


.NOTES
   File Name  : Clear-Manager-for-Users-in-OU.ps1
   Version    : 1.0
   Author     : Andriy Zarevych

.EXAMPLE
   .\Clear-Manager-for-Users-in-OU.ps1 -OU "OU=Users,OU=Disabled Accounts,DC=myDomain,DC=local"

   Description
   -----------
   for users in OU

.EXAMPLE
   .\Clear-Manager-for-Users-in-OU.ps1

   Description
   -----------
   Set default values before run script without parameters.
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

[CmdletBinding()]
Param (
    [string]$OU = "OU=Users,OU=Disabled Accounts,DC=myDomain,DC=local"
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------

Import-Module ActiveDirectory

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host Organizational Unit: $OU

$users = Get-ADUser -SearchBase $OU -Filter *  -properties Manager

foreach ($user in $users) {
    if ($user.Manager -ne $null) {
        $ManagerAccount = get-aduser $user.Manager
        Write-Host Clearing $user.SamAccountName attribute manager. Previous value was: $managerAccount.SamAccountName
        Set-ADUser $user -Manager:$null
    }
    
}
