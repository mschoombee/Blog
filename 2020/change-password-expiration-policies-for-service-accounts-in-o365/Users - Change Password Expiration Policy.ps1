<# 
    ** Check the execution policy for the current machine/user, and set it to unrestricted (if required) ** 

    Get-ExecutionPolicy -List
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine #if you want to set it for the machine
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process #if you want to set it for the current process
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser #if you want to set it for current user only
#>

<#
    ** Install and import the following Power BI management cmdlets (if required) **

    Install-Module -Name AzureAD -AllowClobber
    Import-Module AzureAD
#> 

<# 
    Script Notes
    -----------------------------------------------------------------------------------------

    ** This script will check if a user's password is set to expire, and optionally change it 
       to not expire. You'll typically use this for service accounts, as there is no other way 
       to change the default password policy for specific accounts. 

    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Azure AD\Users - Change Password Expiration Policy.ps1' -UserGuid '00000000-0000-0000-0000-000000000000' -DisablePasswordExpiration 'No'
#>

<#-------------------------------------------------------------------------------------------

Parameters 

-------------------------------------------------------------------------------------------#>

Param 
(    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $UserGuid, 

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet("Yes","No")] 
    [String]
    $DisablePasswordExpiration = "No"
)

<#-------------------------------------------------------------------------------------------

Global actions & variables 

-------------------------------------------------------------------------------------------#>

$ErrorActionPreference = "Stop"
Write-Host "**NOTE: THIS SCRIPT WILL STOP EXECUTING AFTER THE FIRST ERROR**"`r`n -ForegroundColor Yellow 


Try 
{

    <#-------------------------------------------------------------------------------------------

    Connect to Azure AD 

    -------------------------------------------------------------------------------------------#>
    
    #Connect to azure ad tenant
    Connect-AzureAD | Out-Null

    #Get the user's password expiration policy info
    Get-AzureADUser -ObjectId $UserGuid | Select-Object UserprincipalName, @{N="PasswordNeverExpires";E={$_.PasswordPolicies -contains "DisablePasswordExpiration"}}

    #Set the user's password to not expire
    if ($DisablePasswordExpiration -eq "Yes") 
    {
        Set-AzureADUser -ObjectId $UserGuid -PasswordPolicies DisablePasswordExpiration
        Write-Output `n "User password policy set to not expire..." `n 

        #Get the user's password expiration policy info
        Get-AzureADUser -ObjectId $UserGuid | Select-Object UserprincipalName,@{N="PasswordNeverExpires";E={$_.PasswordPolicies -contains "DisablePasswordExpiration"}}
    }

}

Catch
{
    Write-Host ""`n 
    Write-Host "An error has occurred!!" -ForegroundColor Red
    Write-Host "Error Line Number :   $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "Error Command     :   $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
    Write-Host "Error Message     :   $($_.Exception.Message)"`n -ForegroundColor Red 
    Write-Host "Terminating script execution..."`n 
}

Exit


