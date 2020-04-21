#Requires -Version 2.0

<#
.SYNOPSIS
   Get AD domain and forest functional level

.DESCRIPTION
    Script show Active Directory domain and forest functional level, FSMO roles, all sites in the forest, Global Catalog servers

.NOTES
   File Name  : Get-ADInfo.ps1
   Version    : 1.0
   Date       : 2018.08.10
   Author     : Andriy Zarevych

.EXAMPLE
   .\Get-ADInfo.ps1
   
   Description
   -----------
   Get AD domain and forest functional level

#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Forest Info
$ADForest=Get-ADForest

write-host
Write-Host "Forest Name             :" $ADForest.Name
write-host "Forest Functional Level :" $ADForest.ForestMode
Write-Host "Schema master           :" $ADForest.SchemaMaster
Write-Host "Domain naming master    :" $ADForest.DomainNamingMaster

#Domain Info
foreach ($Domain in $ADForest.Domains){
    write-host
    $ADDomain=Get-ADDomain $Domain
    write-host "Domain Name                  :" $Domain
    write-host "Distinguished Name           :" $ADDomain.DistinguishedName
    write-host "Domain Functional Level      :" $ADDomain.DomainMode
    write-host "Domain NetBIOS Name          :" $ADDomain.NetBIOSName
    write-host "PDC Emulator                 :" $ADDomain.PDCEmulator
    write-host "RID master                   :" $ADDomain.RIDMaster
    write-host "Infrastructure master        :" $ADDomain.InfrastructureMaster
    write-host "Domain Controllers Container :" $ADDomain.DomainControllersContainer
    write-host "Computers Container          :" $ADDomain.ComputersContainer
    write-host "Users Container              :" $ADDomain.UsersContainer
}

#Sites
write-host
write-host "Active Directory Sites:"
    foreach ($ADSite in $ADForest.Sites){
        Write-Host "   " $ADSite
    }


#GlobalCatalogs
write-host
write-host "Global Catalog servers:"
    foreach ($GlobalCatalogs in $ADForest.GlobalCatalogs){
        Write-Host "   " $GlobalCatalogs
    }

Write-Host
