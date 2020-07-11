<# 
    ** Check the execution policy for the current machine/user, and set it to unrestricted (if required) ** 

    Get-ExecutionPolicy -List
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine #if you want to set it for the machine
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process #if you want to set it for the current process
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser #if you want to set it for current user only
#>

<#
    ** Install and import the following Power BI management cmdlets (if required) **

    Install-Module -Name MicrosoftPowerBIMgmt -AllowClobber
    Import-Module MicrosoftPowerBIMgmt
#> 

<# 
    Script Notes
    -----------------------------------------------------------------------------------------

    ** This script will restore a workspace, using the original name of the workspace.
    
    ** Note that after restoring it, all data sets and reports will be there as well, but 
       refresh schedules will be disabled and you may have to reenter credentials and parameters.


    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Power BI\Workspaces - Restore Workspace.ps1' -WorkspaceName 'MyWorkspace' -AdminUser 'me@me.com'

    
    Technical References
    -----------------------------------------------------------------------------------------

    Power BI cmdlets
    https://docs.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps 

    Power BI REST APIs
    https://docs.microsoft.com/en-us/rest/api/power-bi/
#>

<#-------------------------------------------------------------------------------------------

Parameters 

-------------------------------------------------------------------------------------------#>

Param 
(    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $WorkspaceName, 

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $AdminUser
)

<#-------------------------------------------------------------------------------------------

Global actions & variables 

-------------------------------------------------------------------------------------------#>

$ErrorActionPreference = "Stop"
Write-Host "**NOTE: THIS SCRIPT WILL STOP EXECUTING AFTER THE FIRST ERROR**"`r`n -ForegroundColor Yellow 


Try {

    <#-------------------------------------------------------------------------------------------

    Connect to Power BI 

    -------------------------------------------------------------------------------------------#>
    
    #Connect to Power BI tenant
    Connect-PowerBIServiceAccount | Out-Null 


    <#-------------------------------------------------------------------------------------------

    Restore the Workspace 

    -------------------------------------------------------------------------------------------#>

    #Retrieve the workspace
    $WorkspaceObject = (Get-PowerBIWorkspace -Scope Organization -Name $WorkspaceName -WarningAction SilentlyContinue) 
    #Write-Output $WorkspaceObject
    
    
    #Restore the workspace if it's in a deleted state
    if (!$WorkspaceObject) {
        Write-Output "Workspace ""$WorkspaceName"" does not exist. Nothing to do here..." `n        
    }

    else {
        #Found the workspace and with a "deleted" status.
        if ($WorkspaceObject.State -eq "Deleted") {
            Write-Output "Found it! Restoring workspace ""$WorkspaceName"" now..."

            #Restore workspace
            Restore-PowerBIWorkspace -Id $WorkspaceObject.Id -RestoredName $WorkspaceName -AdminUserPrincipalName $AdminUser -WarningAction SilentlyContinue

            Write-Output "Workspace ""$WorkspaceName"" restored successfully..." `n
        }

        else {
            #Nothing to do here...
            Write-Output "Workspace ""$WorkspaceName"" exists and in an active state. Nothing to do here..." `n
        }
    }  
}

Catch {
    Write-Host ""`n 
    Write-Host "An error has occurred!!" -ForegroundColor Red
    Write-Host "Error Line Number :   $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "Error Command     :   $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
    Write-Host "Error Message     :   $($_.Exception.Message)"`n -ForegroundColor Red 
    Write-Host "Terminating script execution..."`n 
}

Exit


