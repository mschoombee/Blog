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

    ** This script will create a workspace, restoring it if it already exists in a deleted state.
    
    ** Note that if restored, all datasets and reports will be there as well, but 
       refresh schedules will be disabled and you may have to reenter credentials and parameters.


    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Power BI\Workspaces - Create Workspace.ps1' -WorkspaceName 'MyWorkspace' -WorkspaceDescription 'MyDescription' -AdminUser 'me@me.com'

    
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

param 
(    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $WorkspaceName, 

    [Parameter(Mandatory=$false)]
    [AllowNull()]
    [AllowEmptyString()]
    [String]
    $WorkspaceDescription = $null,

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


try {

    <#-------------------------------------------------------------------------------------------

    Connect to Power BI 

    -------------------------------------------------------------------------------------------#>
    
    #Connect to Power BI tenant
    Connect-PowerBIServiceAccount | Out-Null 


    <#-------------------------------------------------------------------------------------------

    Create the Workspace 

    -------------------------------------------------------------------------------------------#>

    #Retrieve the workspace
    $WorkspaceObject = (Get-PowerBIWorkspace -Scope Organization -Name $WorkspaceName -WarningAction SilentlyContinue) 
    
    #Uncomment the next line if you want to see the details of the workspace
    #Write-Output $WorkspaceObject
    
    
    #Create the workspace, or restore it if it's in a deleted state
    if (!$WorkspaceObject) {

        #Some user-friendly messages :-)
        Write-Output "Workspace ""$WorkspaceName"" does not exist. Creating it now..." `n
    
        #Create new workspace
        New-PowerBIWorkspace -Name $WorkspaceName -OutVariable WorkspaceObject | Out-Null

        #Return completion message if it was created successfully
        if ($WorkspaceObject){

            Write-Output "Workspace ""$WorkspaceName"" successfully created..." `n
        }       
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

    <#-------------------------------------------------------------------------------------------

    Update the description (if provided) 

    -------------------------------------------------------------------------------------------#>

    if (($WorkspaceDescription -eq $null) -or ($WorkspaceDescription -eq "")) {
        
        #Description not provided...do nothing
        Write-Output "Workspace description not provided. All done." `n
    }

    else {

        #Update the description
        Set-PowerBIWorkspace -Scope Organization -Id $WorkspaceObject.Id -Description $WorkspaceDescription -WarningAction SilentlyContinue

        Write-Output "Workspace ""$WorkspaceName"" description updated to ""$WorkspaceDescription"". All done." `n
    }
}

catch {
    Write-Host ""`n 
    Write-Host "An error has occurred!!" -ForegroundColor Red
    Write-Host "Error Line Number :   $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "Error Command     :   $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
    Write-Host "Error Message     :   $($_.Exception.Message)"`n -ForegroundColor Red 
    Write-Host "Terminating script execution..."`n 
}

exit


