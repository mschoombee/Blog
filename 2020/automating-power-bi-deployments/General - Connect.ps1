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

    ** This script shows the different ways to connect to a Power BI tenant. It isn't meant to 
    run as a unit, so use if for testing purposes only.

    
    Technical References
    -----------------------------------------------------------------------------------------

    Power BI cmdlets
    https://docs.microsoft.com/en-us/powershell/power-bi/overview?view=powerbi-ps 

    Power BI REST APIs
    https://docs.microsoft.com/en-us/rest/api/power-bi/
#>

<#-------------------------------------------------------------------------------------------

Interactive Connection - Running this cmdlet will prompt the user to connect

-------------------------------------------------------------------------------------------#>

Connect-PowerBIServiceAccount



<#-------------------------------------------------------------------------------------------

Automated Connection - Running the code below will connect without user prompts 

Note: 
** The account you're using will need Power BI administrator permissions. 
** The method below will not work if MFA is required for the account.

-------------------------------------------------------------------------------------------#>

#Variables 
$PbiUser = "me@me.com"
$PbiPassword = "MyPassword"

#Create secure string for password 
$PbiSecurePassword = ConvertTo-SecureString $PbiPassword -Force -AsPlainText
$PbiCredential = New-Object Management.Automation.PSCredential($PbiUser, $PbiSecurePassword)

#Connect to the Power BI service
Connect-PowerBIServiceAccount -Credential $PbiCredential

