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

    ** This script will deploy a pbix file (report/dataset combination), overwriting it if it 
       already exists.
    
    ** Note that we're ignoring an edge-case "error" in this script, if more than one reports 
       are associated with the dataset we're attempting to overwrite.


    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Power BI\Reports - Deploy Report.ps1' -WorkspaceName 'MyWorkspace' -PbixFilePath 'c:\my report.pbix' -ReportName 'MyReportName'

    
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
    $PbixFilePath, 

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $ReportName
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

    Deploy .pbix file 

    -------------------------------------------------------------------------------------------#>

    #Retrieve the workspace
    $WorkspaceObject = (Get-PowerBIWorkspace -Scope Organization -Name $WorkspaceName)

    try {

        #Deploy pbix file
        New-PowerBIReport -Workspace $WorkspaceObject -Path $PbixFilePath -Name $ReportName -ConflictAction CreateOrOverwrite | Out-Null
    } 

    catch { 
        
        #This "error" means that there were more than one report associated with the dataset, so we're going to ignore it and continuing
        if ($_.Exception.Message -ccontains "Sequence contains more than one element") { 
            
            Write-Output "More than one report was associated with this dataset. We're ignoring the ""error"" and continuing..." `n

            #It's a non-terminating error, but we'll clear it to be safe 
            $error.Clear()
            
        }

        #A real error occurred, so throw it
        else { 

            throw 
            
        }
    } 

    #Retrieve the newly deployed report
    $PbiReportObject = (Get-PowerBIReport -Workspace $WorkspaceObject -Name $ReportName) 

    #Check to see if it's been deployed successfully
    if ($PbiReportObject) {

        Write-Output "Report ""$ReportName"" successfully deployed..." `n
    }

    else {

        #throw an error if it hasn't been deployed successfully (i.e. the variable is empty)
        throw "Hmmm...something went wrong. The report was not deployed :-/"
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


