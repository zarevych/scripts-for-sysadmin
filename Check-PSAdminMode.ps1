<#

In Powershell 4.0 you can use requires at the top of your script:
#Requires -RunAsAdministrator

#>

function Check-PSAdminPermission (){
   if (-NOT ([Security.Principal.WindowsPrincipal]`
      [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
      [Security.Principal.WindowsBuiltInRole] "Administrator")) {
         Return $false
   }
   else {
         Return $true
   }
}
 
Write-Host "Checking for administrative privileges …"
if (Check-PSAdminPermission) {
    Write-Host "Administrator permission detected" -ForegroundColor Green
}
else {
   Write-Host "Not enough rights to run this script `nOpen the PowerShell console with administrator privileges and run the script again" -ForegroundColor Yellow
    Break
}
 
Write-Host "Continue the script..."