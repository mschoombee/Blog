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

    ** This script will trigger a dataset refresh.

    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Power BI\Reports - Trigger Refresh.ps1' -WorkspaceName 'MyWorkspace' -DatasetName 'MyDatasetName'

    
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

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $DatasetName
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

    Retrieve workspace and report objects

    -------------------------------------------------------------------------------------------#>

    #Retrieve the workspace
    $WorkspaceObject = (Get-PowerBIWorkspace -Scope Organization -Name $WorkspaceName)

    #Retrieve the dataset
    $PbiDatasetObject = (Get-PowerBIDataset -Scope Organization -Workspace $WorkspaceObject -Name $DatasetName)
    

    <#-------------------------------------------------------------------------------------------

    Trigger dataset refresh 

    -------------------------------------------------------------------------------------------#>

    #API url for the refresh
    $ApiUrl = "groups/" + $WorkspaceObject.Id + "/datasets/" + $PbiDatasetObject.Id + "/refreshes" 

    $ApiRequestBody = @"
        {
            "type": "Full", 
            "notifyOption": "MailOnCompletion"
        }
"@ 


    #Trigger refresh
    Invoke-PowerBIRestMethod -Url $ApiUrl -Method Post -Body ("$ApiRequestBody") -Verbose
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
