<#
.SYNOPSIS
 Get Inactive AD User in Domain based on Last Logon Time Stamp

.DESCRIPTION
 Get Inactive AD User in Domain based on Last Logon Time Stamp

 Requirement of the script:
    - Active Directory PowerShell Module

.NOTES
   File Name  : Get-InactiveADUsers-CSV.ps1
   Author     : Andriy Zarevych

   Change Log:
   V0.1702    : Initial version
#>



Import-Module ActiveDirectory


# --- CHANGE THESE VALUES ---
$OU = "OU=CompanyUsers,DC=contoso,DC=com" #"OU=CompanyUsers,DC=contoso,DC=com" or "DC=contoso,DC=com"

$InactiveDays = 90 #Last logon days

[string]$LogFile = ".\InActiveADUsers_$(Get-Date -f 'yyyy-MM-dd').csv" #CSV-file path
[string]$strDelimiter = ";" #CSV-file delimiter
# ------------------------------------------------------



$time = (Get-Date).Adddays(-($InactiveDays)) 

if (Test-Path $LogFile){
    #Remove-Item $LogFile
    Clear-Content $LogFile
}

$strToReport = "Name" + $strDelimiter + "UserPrincipalName" + $strDelimiter + "EmployeeID" + $strDelimiter + "Enabled" + $strDelimiter + "LastLogonDate" + $strDelimiter + "LastLogonTime" + $strDelimiter + "DistinguishedName"
Add-Content $LogFile $strToReport

# Get all AD User with lastLogonTimestamp less than our time and enabled:$true
$Users = Get-ADUser -SearchBase $OU -SearchScope Subtree -Filter { (enabled -eq "true") -and (objectclass -eq "user") -and (LastLogonTimeStamp -lt $time) } -Properties LastLogonTimeStamp

foreach ($User in $Users) {

    $uDate = [DateTime]::FromFileTime($User.LastLogonTimeStamp).ToString('yyyy-MM-dd hh:mm:ss')
    $uTime = [DateTime]::FromFileTime($User.LastLogonTimeStamp).ToString('hh:mm:ss')

    #Name UserPrincipalName EmployeeID DistinguishedName Enabled $uDate $uTime
    $strToReport = $User.Name + $strDelimiter + $User.UserPrincipalName + $strDelimiter + $User.EmployeeID + $strDelimiter + $User.Enabled + $strDelimiter + $uDate + $strDelimiter + $uTime + $strDelimiter + $User.DistinguishedName
    Add-Content $LogFile $strToReport
    write-host $User.Name $User.UserPrincipalName $User.EmployeeID $User.Enabled $uDate

}