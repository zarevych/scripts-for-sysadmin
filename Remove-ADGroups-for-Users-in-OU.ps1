#Requires -Version 2.0

<#
.SYNOPSIS
   Remove AD Groups for Users in specific OU

.DESCRIPTION
   This script remove all Active Directory (AD) groups for users in specific Organizational Unit (OU).
   Except group "Domain Users"
   Needed rights in AD for remove users from groups.
   For example - Domain Admins
   
   Section Initialisations
   To set default value for parameter OU in line:
      [string]$OU =
   set value
      [string]$OU = "OU=Users,OU=Disabled Accounts,DC=myDomain,DC=local"

   To set auto-confirm removing from groups in line:
      $Confirm = 
   set value $false
      $Confirm = $False
   
   Set default values before run script without parameters.

   Script can be useful for disabled users accounts.

.PARAMETER OU
   Uses to specify Organizational Unit (OU) with users.
   If OU not specified, script uses defaul value
   See parameter defaul value in line:
      [string]$OU =
   Example to use: -OU "OU=Users,OU=Disabled Accounts,DC=myDomain,DC=local"

.PARAMETER Confirm
   Uses for auto-confirm removing from groups.
   If parameter not specified, script uses defaul value
   See defaul value in line:
      $Confirm =
   Example to use auto-confirm: -Confirm:$false


.NOTES
   File Name  : Remove-ADGroups-for-Users-in-OU.ps1
   Version    : 1.0
   Author     : Andriy Zarevych

.EXAMPLE
   .\Remove-ADGroups-for-Users-in-OU.ps1 -OU "OU=Users,OU=Disabled Accounts,DC=myDomain,DC=local" -Confirm:$False

   Description
   -----------
   Remove all groups for users in OU with auto-confirm.

.EXAMPLE
   .\Remove-ADGroups-for-Users-in-OU.ps1

   Description
   -----------
   Set default values before run script without parameters.
#>


#---------------------------------------------------------[Initialisations]--------------------------------------------------------

[CmdletBinding()]
Param (
    [string]$OU = "OU=Users,OU=Disabled Accounts,DC=myDomain,DC=local",
    $Confirm = $True
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------

$ExceptGroup = "Domain Users"

Import-Module ActiveDirectory

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host Organizational Unit: $OU
Write-Host Confirm: $Confirm

$users = Get-ADUser -SearchBase $OU -Filter *

foreach ($user in $users) {
    $UserDN = $user.DistinguishedName
    Get-ADGroup -LDAPFilter "(member=$UserDN)" | foreach-object {
        if ($_.name -ne $ExceptGroup) {
            Write-Host Removing $user.SamAccountName from group $_.name
            Remove-ADGroupMember -identity $_.name -Member $UserDN -Confirm:$Confirm
        }
    }
}
