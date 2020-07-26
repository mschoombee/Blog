<# 
    ** Check the execution policy for the current machine/user, and set it to unrestricted (if required) ** 

    Get-ExecutionPolicy -List
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine #if you want to set it for the machine
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process #if you want to set it for the current process
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser #if you want to set it for current user only
#>

<#
    ** Install and import the following cmdlets (if required) **

    Install-Module -Name <module name> -AllowClobber
    Import-Module <module name>
#> 

<# 
    Script Notes
    -----------------------------------------------------------------------------------------

    ** This script will... 

    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\...\General - PoSh Script Template.ps1'

    
    Technical References
    -----------------------------------------------------------------------------------------

    <references>
#>

<#-------------------------------------------------------------------------------------------

Global actions & variables 

-------------------------------------------------------------------------------------------#>

$ErrorActionPreference = "Stop"
Write-Host "**NOTE: THIS SCRIPT WILL STOP EXECUTING AFTER THE FIRST ERROR**"`r`n -ForegroundColor Yellow 


Try 
{

    <#-------------------------------------------------------------------------------------------

    Section 1

    -------------------------------------------------------------------------------------------#>
    
    <code>

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


