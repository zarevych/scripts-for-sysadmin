#Requires -Version 2.0

<#
.SYNOPSIS
 Get BitLocker Recovery Information for computer from Active Directory.
 Generates a file with computer names and BitLocker Recovery Keys.

.DESCRIPTION
 Get BitLocker Recovery Information for Computer from Active Directory

 Requirement of the script:
    - Active Directory PowerShell Module
    - Needed rights to view AD BitLocker Recovery Info

 Usage:
    .\Get-ADComputer-BitLockerInfo.ps1 -OU "OU=Computers,OU=Lviv,DC=myDomain,DC=local" -LogFile .\BitlockerInfo.txt

.PARAMETER OU
    Optional Parameter to narrow the scope of the script

.PARAMETER ComputerName
    Optional parameter to view info about computer
    If set both parameters -OU and -ComputerName script uses parameter ComputerName

.PARAMETER Logfile
    Optional parameter to write info to a file
    
    If set parameter -OU script write info to file like:
    
        ComputerName;Date;Time;GMT;PasswordID;RecoveryPassword;Computer.DistinguishedName;BitLockerObject
    
    If set parameter -ComputerName script write info to file like:

        Computer:
        Date:
        Password ID:
        Recovery Password:
        DistinguishedName:

.NOTES
   File Name  : Get-ADComputer-BitLockerInfo.ps1
   Version    : 2.0
   Date       : 2018.07.03
   Author     : Andriy Zarevych

.EXAMPLE
   .\Get-ADComputer-BitLockerInfo.ps1 -OU "OU=Computers,OU=Lviv,DC=myDomain,DC=local" -LogFile .\BitlockerInfo.txt

   Description
   -----------
   Generates a file with computer names and BitLocker Recovery Keys for computers in targed OU

.EXAMPLE
   .\Get-ADComputer-BitLockerInfo.ps1 -ComputerName PC-1807

   Description
   -----------
   Get BitLocker Recovery Infor for targed computer

#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

[CmdletBinding()]
Param (
    [string]$OU,
    [string]$ComputerName,
    [string]$LogFile  
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------

Import-Module ActiveDirectory

#LogFormat: 0 - Info to Screen; 1 - Info to CSV-format if -OU defined; 2 - Info about Computer
$LogFormat = 0

#To separating fields for report with parameter $LogFormat = 2
$delimiter = ";"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Set scope
if ($ComputerName -ne "") {
    $Computers = Get-ADComputer $ComputerName
    if ($LogFile -ne "") {
        $LogFormat = 2
    }
}
elseif ($OU -ne "") {
    Write-Host "Organizational Unit:" $OU
    $Computers = Get-ADComputer -Filter 'ObjectClass -eq "computer"' -SearchBase $OU
    if ($LogFile -ne "") {
        $LogFormat = 1
    }
}
else {
    Write-Host "Domain:" $env:userdnsdomain
    $Computers = Get-ADComputer -Filter 'ObjectClass -eq "computer"'
    if ($LogFile -ne "") {
        $LogFormat = 1
    }

}
Write-host

if ($LogFormat -eq 1) {
    $strToReport = "ComputerName" + $delimiter + "Date" + $delimiter + "Time" + $delimiter + "GMT" + $delimiter + "PasswordID" + $delimiter + "RecoveryPassword" + $delimiter + "Computer.DistinguishedName" + $delimiter + "BitLockerObject"
    $strToReport | Out-File $LogFile
}

#Get BitLocker Recovery Info
foreach ($Computer in $Computers) {

    $BitLockerObjects=(Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $Computer.DistinguishedName -Properties msFVE-RecoveryPassword)

    foreach ($BitLockerObject in $BitLockerObjects) {
    
        #The name of the BitLocker recovery object incorporates a globally unique identifier (GUID) and date and time information, 
        #for a fixed length of 63 characters. The form is: <Object Creation Date and Time><Recovery GUID>
        #For example:
        #2005-09-30T17:08:23-08:00{063EA4E1-220C-4293-BA01-4754620A96E7}
        #$BitLockerObject.Name
        $strComputerDate = $BitLockerObject.Name.Substring(0,10)
        $strComputerTime = $BitLockerObject.Name.Substring(11,8)
        $strComputerGMT = $BitLockerObject.Name.Substring(19,6)
        $strComputerPasswordID = $BitLockerObject.Name.Substring(26,36)
        $strComputerRecoveryPassword = $BitLockerObject.'msFVE-RecoveryPassword'

        Write-host "Computer:" $Computer.Name
        Write-Host "Date:" $strComputerDate $strComputerTime $strComputerGMT
        Write-Host "Password ID:" $strComputerPasswordID
        Write-Host "Recovery Password:" $BitLockerObject.'msFVE-RecoveryPassword'
        Write-Host "DistinguishedName:" $Computer.DistinguishedName
        Write-Host
        
        if ($LogFormat -eq 2) {
            $strToReport = "Computer: "+$Computer.Name
            $strToReport | Out-File $LogFile -append
            $strToReport = "Date: " + $strComputerDate + " " + $strComputerTime + " " + $strComputerGMT
            $strToReport | Out-File $LogFile -append
            $strToReport = "Password ID: " + $strComputerPasswordID
            $strToReport | Out-File $LogFile -append
            $strToReport = "Recovery Password :" + " " + $BitLockerObject.'msFVE-RecoveryPassword'
            $strToReport | Out-File $LogFile -append
            $strToReport = "DistinguishedName: " + " " + $Computer.DistinguishedName
            $strToReport | Out-File $LogFile -append
            $strToReport = ""
            $strToReport | Out-File $LogFile -append
        }

        if ($LogFormat -eq 1) {
            $strToReport = $Computer.Name + $delimiter + $strComputerDate + $delimiter + $strComputerTime + $delimiter + $strComputerGMT + $delimiter + $strComputerPasswordID + $delimiter + $strComputerRecoveryPassword + $delimiter + $Computer + $delimiter + $BitLockerObject
            $strToReport | Out-File $LogFile -append
        }
    }

}
