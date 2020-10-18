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

    ** This script will update credentials (username & password) for all SQL Server data sources in a report.

    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Power BI\Reports - Change Data Source Credentials.ps1' -WorkspaceName 'MyWorkspace' -ReportName 'MyReportName' -DataSourceUser 'MyDataSourceUserName' -DataSourcePassword 'MyDataSourcePassword'

    
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
    $DataSourceUser,
     
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $DataSourcePassword
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

    Retrieve workspace, report and data source objects

    -------------------------------------------------------------------------------------------#>

    #Retrieve the workspace
    $WorkspaceObject = (Get-PowerBIWorkspace -Scope Organization -Name $WorkspaceName)

    #Retrieve the report
    $PbiReportObject = (Get-PowerBIReport -Workspace $WorkspaceObject -Name $ReportName)

    #Retrieve all data sources
    $PbiDataSourcesObject = (Get-PowerBIDatasource -DatasetId $PbiReportObject.DatasetId -Scope Organization)


    <#-------------------------------------------------------------------------------------------

    Iterate through data sources and update credentials for all SQL Server sources

    -------------------------------------------------------------------------------------------#>

    foreach ($DataSource in $PbiDataSourcesObject) {

        #Store the data source id in a variable (for ease of use later)
        $DataSourceId = $DataSource.DatasourceId

        #API url for data source
        $ApiUrl = "gateways/" + $DataSource.GatewayId + "/datasources/" + $DataSourceId

        #Format username and password, replacing escape characters for the body of the request
        $FormattedDataSourceUser = $DataSourceUser.Replace("\", "\\")
        $FormattedDataSourcePassword = $DataSourcePassword.Replace("\", "\\")
        
        #Build the request body
        $ApiRequestBody = @"
            {
                "credentialDetails": {
                    "credentialType": "Basic", 
                    "credentials": "{\"credentialData\":[{\"name\":\"username\", \"value\":\"$FormattedDataSourceUser\"}, {\"name\":\"password\", \"value\":\"$FormattedDataSourcePassword\"}]}",
                    "encryptedConnection": "Encrypted",
                    "encryptionAlgorithm": "None",
                    "privacyLevel": "Organizational"
                }
            }
"@
 

        #If it's a sql server source, change the username/password
        if ($DataSource.DatasourceType = "Sql") {

            #Update username & password
            Invoke-PowerBIRestMethod -Url $ApiUrl -Method Patch -Body ("$ApiRequestBody")

            Write-Output "Credentials for data source ""$DataSourceId"" successfully updated..." `n
        }

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


