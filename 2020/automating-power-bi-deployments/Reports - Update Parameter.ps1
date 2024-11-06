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

    ** This script will update a dataset parameter "Customer Name" in a report.

    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Power BI\Reports - Update Parameters.ps1' -WorkspaceName 'MyWorkspace' -ReportName 'MyReportName' -CustomerName 'MyCustomerName'

    
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
    $ReportName, 

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $CustomerName
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

    #Retrieve the report
    $PbiReportObject = (Get-PowerBIReport -Workspace $WorkspaceObject -Name $ReportName)


    <#-------------------------------------------------------------------------------------------

    Update parameters

    -------------------------------------------------------------------------------------------#>

    #API url for parameters
    $ApiUrl = "groups/" + $WorkspaceObject.Id + "/datasets/" + $PbiReportObject.DatasetId + "/Default.UpdateParameters"

    #Build the request body
    $ApiRequestBody = @"
    {
        "updateDetails": [        
            {
                "name": "Customer Name", "newValue": "$CustomerName"
            }
        ]
    }
"@

    #Update parameters
    Invoke-PowerBIRestMethod -Url $ApiUrl -Method Post -Body ("$ApiRequestBody")

    Write-Output "Parameter ""Customer Name"" in report ""$ReportName"" sucessfully updated to ""$CustomerName""..." `n
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


