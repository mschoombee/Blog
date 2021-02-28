<# 
    ** Check the execution policy for the current machine/user, and set it to unrestricted (if required) ** 

    Get-ExecutionPolicy -List
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine #if you want to set it for the machine
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process #if you want to set it for the current process
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser #if you want to set it for current user only
#>

<#
    ** Install and import the following cmdlets (if required) **

    Install-Module -Name AzureAD -AllowClobber
    Import-Module AzureAD
#> 

<# 
    Script Notes
    -----------------------------------------------------------------------------------------

    ** This script will assign an Administrator role in Azure AD to a user or service principal, enabling the role if needed from the template. 
       You can use either the email address or display name of the user, and display name or app id of the service principal.

    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Azure AD\Roles - Assign Administrator Role.ps1' AdminRole 'Intune Administrator' -User 'me@me.com' 
#>

<#-------------------------------------------------------------------------------------------

Parameters 

-------------------------------------------------------------------------------------------#>

Param 
(    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $AdminRole,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()] 
    [String]
    $User
)

<#-------------------------------------------------------------------------------------------

Global actions & variables 

-------------------------------------------------------------------------------------------#>

$ErrorActionPreference = "Stop"
Write-Host "**NOTE: THIS SCRIPT WILL STOP EXECUTING AFTER THE FIRST ERROR**"`r`n -ForegroundColor Yellow 


try {

    <#-------------------------------------------------------------------------------------------

    Connect to Azure AD 

    -------------------------------------------------------------------------------------------#>
    
    #Connect to Azure AD tenant
    Connect-AzureAD | Out-Null


    <#-------------------------------------------------------------------------------------------

    Get the admin role, or enable it if necessary

    -------------------------------------------------------------------------------------------#>

    #Get the AD role
    $AdminRoleObject = (Get-AzureADDirectoryRole | where {$_.DisplayName -eq $AdminRole}) 
    
    if (-not $AdminRoleObject) { 
        
        #Role doesn't exist in the tenant, so let's get the template
        $AdminRoleTemplateObject = (Get-AzureADDirectoryRoleTemplate | where {$_.DisplayName -eq $AdminRole}) 

        if ($AdminRoleTemplateObject) {

            #Found it...now enable it
            Enable-AzureADDirectoryRole -RoleTemplateId $AdminRoleTemplateObject.ObjectId | Out-Null

            Write-Output `n "The template for the ""$AdminRole"" role was found and successfully enabled." 

            #Assign it to the object now that we've enabled it
            $AdminRoleObject = (Get-AzureADDirectoryRole | where {$_.DisplayName -eq $AdminRole})
        }
        else {

            #Couldn't find the role or template...time to throw an error
            throw "Could not find the admin role or template :-/"
        }
        
    }


    <#-------------------------------------------------------------------------------------------

    Get the user or service principal and assign role

    -------------------------------------------------------------------------------------------#>

    #Attempt to get the user by either principal or display name
    $UserObject = (Get-AzureADUser | where {($_.UserPrincipalName -eq $User) -or ($_.DisplayName -eq $User)})
    
    #If the user isn't found, try to find a service principal with that name or App Id
    if (-not $UserObject) {

        $UserObject = (Get-AzureADServicePrincipal | where {($_.AppId -eq $User) -or ($_.DisplayName -eq $User)})
        
        if (-not $UserObject) {

            #Couldn't find the user or service principal...time to throw an error
            throw "Could not find the user or service principal :-/"

        }
        else {

            #Assign the role to the service principal
            Add-AzureADDirectoryRoleMember -ObjectId $AdminRoleObject.ObjectId -RefObjectId $UserObject.ObjectId 

            Write-Output `n "The admin role ""$AdminRole"" role was successfully assigned to service principal ""$User""."

        }
        
    }
    else {

        #Assign the role to the user
        Add-AzureADDirectoryRoleMember -ObjectId $AdminRoleObject.ObjectId -RefObjectId $UserObject.ObjectId 

        Write-Output `n "The admin role ""$AdminRole"" role was successfully assigned to user ""$User""."

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


