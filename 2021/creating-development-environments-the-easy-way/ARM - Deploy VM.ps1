<# 
    ** Check the execution policy for the current machine/user, and set it to unrestricted (if required) ** 

    Get-ExecutionPolicy -List
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine #if you want to set it for the machine
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process #if you want to set it for the current process
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser #if you want to set it for current user only
#>

<#
    ** Install and import the following Azure Cmdlets (if required) **

    Install-Module -Name Az -AllowClobber
    Import-Module Az
#> 

<# 
    Script Notes
    -----------------------------------------------------------------------------------------

    ** This script will use the referenced ARM template and create a development VM. 

    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'D:\Resources\PowerShell\Azure RM\ARM - Deploy VM.ps1' -CustomerName 'Customer1' -CustomerPrefix 'c1' -Location 'East US 2' -AdminUser 'mschoombee' -AdminPassword 'xxxxx' -SecurityRuleIpAddress '127.0.0.1' -TemplateFile 'D:\\Dropbox\\28twelve\Resources\\Azure RM\\ARM Template - VM - Development.json'
#>

<#-------------------------------------------------------------------------------------------

Parameters 

-------------------------------------------------------------------------------------------#>

Param 
(    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $SubscriptionId,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $CustomerName,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $CustomerPrefix,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $Location,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $AdminUserName,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $AdminPassword,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $SecurityRuleIpAddress, 

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $TemplateFile
)

<#-------------------------------------------------------------------------------------------

Global actions & variables 

-------------------------------------------------------------------------------------------#>

$ErrorActionPreference = "Stop"
Write-Host "**NOTE: THIS SCRIPT WILL STOP EXECUTING AFTER THE FIRST ERROR**"`r`n -ForegroundColor Yellow 


try 
{

    <#-------------------------------------------------------------------------------------------

    Connect to Azure Tenant 

    -------------------------------------------------------------------------------------------#>
    
    #Connect to azure tenant and set context to subscription
    Connect-AzAccount | Out-Null
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null


    <#-------------------------------------------------------------------------------------------

    Create Resource Group 

    -------------------------------------------------------------------------------------------#> 

    #Derive the resource group name
    $ResourceGroupName = "28t-rg-$CustomerPrefix"

    #Create or update the resource group
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag @{Customer="$CustomerName"} -Force


    <#-------------------------------------------------------------------------------------------

    Deploy Development VM

    -------------------------------------------------------------------------------------------#>
    $DeploymentDate = (Get-Date -format "yyyyMMdd")
    $DeploymentName = "$DeploymentDate-VM-28t-vm-$CustomerPrefix-dev"

    #ARM template parameter object
    $ParameterObject = @{
        "_SubscriptionId"           = "$SubscriptionId"
        "_CustomerName"             = "$CustomerName"
        "_CustomerPrefix"           = "$CustomerPrefix"
        "_Location"                 = "$Location"
        "_AdminUserName"            = "$AdminUserName"
        "_AdminPassword"            = "$AdminPassword"
        "_SecurityRuleIpAddress"    = "$SecurityRuleIpAddress"
}

    #Parameters for the cmdlet
    $Parameters = @{
        "Name"                      = "$DeploymentName"
        "TemplateFile"              = "$TemplateFile"
        "TemplateParameterObject"   = $ParameterObject
        "Verbose"                   = $true
}

    #Create deployment
    New-AzResourceGroupDeployment -ResourceGroupName "$ResourceGroupName" @Parameters   

}

catch
{
    Write-Host ""`n 
    Write-Host "An error has occurred!!" -ForegroundColor Red
    Write-Host "Error Line Number :   $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    Write-Host "Error Command     :   $($_.InvocationInfo.Line.Trim())" -ForegroundColor Red
    Write-Host "Error Message     :   $($_.Exception.Message)"`n -ForegroundColor Red 
    Write-Host "Terminating script execution..."`n 
}

exit


