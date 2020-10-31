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

    ** This script will assign user, group or app permissions to a workspace. 
    ** You can assign the following permissions: Admin, Contributor, Member, None, Viewer
    ** Assigning the "None" permission will effectively remove the user/group/app permission

    ** Execute this script in the following way in a PowerShell session (run as admin)
        ex. &'c:\PowerShell\Power BI\Workspaces - Assign Permissions.ps1' -WorkspaceName 'MyWorkspace' -Users 'User1@me.com|Admin;User2@me.com|Member' -Groups 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx|Contributor' -Apps 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx|Contributor'

    
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
    [ValidateNotNullOrEmpty()]
    [String]
    $Users, 

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Groups, 

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [String]
    $Apps
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

    Retrieve workspace & set global variables

    -------------------------------------------------------------------------------------------#>

    #Retrieve the workspace
    $WorkspaceObject = (Get-PowerBIWorkspace -Scope Organization -Name $WorkspaceName) 


    #API url for the workspace users/groups/apps
    $ApiUrl = "groups/" + $WorkspaceObject.Id + "/users" 

    #Get a list of all workspace users/groups/apps, to see if we need to add or update the user
    $WorkspaceUsers = (Invoke-PowerBIRestMethod -Url $ApiUrl -Method Get) | ConvertFrom-Json
    
    
    <#-------------------------------------------------------------------------------------------

    Add/Update workspace users

    -------------------------------------------------------------------------------------------#> 
    
    #Check if the optional parameter was provided
    if ($Users -ne "") {

        #Split the string and iterate through the items (users)
        foreach ($UserRolePair in $Users.Split(";")) {

            $UserName = $UserRolePair.Split("|")[0]
            $UserRole = $UserRolePair.Split("|")[1] 

            #API request body for user permissions
            $ApiRequestBody = @"
            {
                "groupUserAccessRight": "$UserRole",
                "identifier": "$UserName",
                "principalType": "User"
            }
"@ 

            #See if the user already exists in the list of workspace users/groups/apps, and if so only update its role            
            if ($UserName -cin $WorkspaceUsers.Value.identifier) {

                if ($UserRole -eq "None") {

                    #Remove the user
                    Invoke-PowerBIRestMethod -Url ($ApiUrl + "/$UserName") -Method Delete

                    Write-Output "User ""$UserName"" was removed from the workspace ""$WorkspaceName""..." `n 
                }
                else { 

                    Write-Output "User ""$UserName"" already exists in workspace ""$WorkspaceName"". Updating its role only..." 

                    #Update the user's role
                    Invoke-PowerBIRestMethod -Url $ApiUrl -Method Put -Body ("$ApiRequestBody")

                    Write-Output "User ""$UserName"" granted the ""$UserRole"" role..." `n 
                }
                
            }
            
            #User doesn't exist, so we add it
            else { 

                if ($UserRole -eq "None") {
                    
                    #User doesn't exist, so there's nothing to do
                    Write-Output "User ""$UserName"" cannot be removed from the workspace ""$WorkspaceName"" because it doesn't exist..." `n 
                }
                else { 

                    #Add the user and assign the role
                    Invoke-PowerBIRestMethod -Url $ApiUrl -Method Post -Body ("$ApiRequestBody")

                    Write-Output "User ""$UserName"" added to workspace ""$WorkspaceName"" as ""$UserRole""..." `n 
                }
            }
        }
    }


    <#-------------------------------------------------------------------------------------------

    Add/Update workspace groups

    -------------------------------------------------------------------------------------------#> 
    
    #Check if the optional parameter was provided
    if ($Groups -ne "") {

        #Split the string and iterate through the items (groups)
        foreach ($GroupRolePair in $Groups.Split(";")) {

            $GroupGuid = $GroupRolePair.Split("|")[0]
            $GroupRole = $GroupRolePair.Split("|")[1] 

            #API request body for group permissions
            $ApiRequestBody = @"
            {
                "groupUserAccessRight": "$GroupRole",
                "identifier": "$GroupGuid",
                "principalType": "Group"
            }
"@ 

            #See if the group already exists in the list of workspace users/groups/apps, and if so only update its role            
            if ($GroupGuid -cin $WorkspaceUsers.Value.identifier) {

                if ($GroupRole -eq "None") {

                    #Remove the group
                    Invoke-PowerBIRestMethod -Url ($ApiUrl + "/$GroupGuid") -Method Delete

                    Write-Output "Group ""$GroupGuid"" was removed from the workspace ""$WorkspaceName""..." `n 
                }
                else {

                    Write-Output "Group ""$GroupGuid"" already exists in workspace ""$WorkspaceName"". Updating its role only..." 

                    #Update the group's role
                    Invoke-PowerBIRestMethod -Url $ApiUrl -Method Put -Body ("$ApiRequestBody")

                    Write-Output "Group ""$GroupGuid"" granted the ""$GroupRole"" role..." `n 
                }
            }
            
            #Group doesn't exist, so we add it
            else { 

                if ($GroupRole -eq "None") {
                    
                    #Group doesn't exist, so there's nothing to do
                    Write-Output "Group ""$GroupGuid"" cannot be removed from the workspace ""$WorkspaceName"" because it doesn't exist..." `n 
                }
                else { 

                    #Add the group and assign the role
                    Invoke-PowerBIRestMethod -Url $ApiUrl -Method Post -Body ("$ApiRequestBody")

                    Write-Output "Group ""$GroupGuid"" added to workspace ""$WorkspaceName"" as ""$GroupRole""..." `n 
                }
            }
        }
    }


    <#-------------------------------------------------------------------------------------------

    Add/Update workspace service principals (apps)

    -------------------------------------------------------------------------------------------#> 
    
    #Check if the optional parameter was provided
    if ($Apps -ne "") {

        #Split the string and iterate through the items (apps)
        foreach ($AppRolePair in $Apps.Split(";")) {

            $AppGuid = $AppRolePair.Split("|")[0]
            $AppRole = $AppRolePair.Split("|")[1] 

            #API request body for app permissions
            $ApiRequestBody = @"
            {
                "groupUserAccessRight": "$AppRole",
                "identifier": "$AppGuid",
                "principalType": "App"
            }
"@ 

            #See if the app already exists in the list of workspace users/groups, and if so only update its role            
            if ($AppGuid -cin $WorkspaceUsers.Value.identifier) {
                
                if ($AppRole -eq "None") {

                    #Remove the app
                    Invoke-PowerBIRestMethod -Url ($ApiUrl + "/$AppGuid") -Method Delete

                    Write-Output "App ""$AppGuid"" was removed from the workspace ""$WorkspaceName""..." `n 
                }
                else {

                    Write-Output "App ""$AppGuid"" already exists in workspace ""$WorkspaceName"". Updating its role only..." 

                    #Update the app's role
                    Invoke-PowerBIRestMethod -Url $ApiUrl -Method Put -Body ("$ApiRequestBody")

                    Write-Output "App ""$AppGuid"" granted the ""$AppRole"" role..." `n 
                }
            }
            
            #App doesn't exist, so we add it
            else { 
                
                if ($AppRole -eq "None") {
                    
                    #App doesn't exist, so there's nothing to do
                    Write-Output "App ""$AppGuid"" cannot be removed from the workspace ""$WorkspaceName"" because it doesn't exist..." `n 
                }
                else { 

                    #Add the app and assign the role
                    Invoke-PowerBIRestMethod -Url $ApiUrl -Method Post -Body ("$ApiRequestBody") -Verbose

                    Write-Output "App ""$AppGuid"" added to workspace ""$WorkspaceName"" as ""$AppRole""..." `n 
                }
            }
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


