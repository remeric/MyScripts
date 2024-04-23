<#
    .Description
    Verify the Account, Tenant, and Sub being used for Azure CLI and AZ Powershell, and verify they match.
#>

function Get-MyContext {

    Write-Host "Checking for Logins..."
    #Verify Logins
    $ErrorActionPreference = "stop"
    try {
        az account show --output none
        if ($? -eq $false) {
            }
        }
        catch {
            Throw "Terminating, AZ CLI not logged in, please run set-mycontext"
        }
    $ErrorActionPreference = "Continue"

    $azcontext = Get-AzContext
    if ($null -eq $azcontext) {
            Throw "Terminating, AZ Powershell not logged in, please run set-mycontext"
    }

    Write-Host "Setting variables"
    #Set variables
    $pscontext = Get-AzContext
    $clsub = az account show --query "id" -otsv
    $clsubname = az account subscription show --subscription-id $clsub --query "displayName" -otsv --only-show-errors
    $cltenant = az account show --query "tenantId" -otsv
    #Need to figure out how to get from AZ CLI the tenant name, for now at least pulling Tenant ID, will test
    $cltenantname = Get-AzTenant -TenantId $cltenant | Select-Object name
    $cluser = az account show --query "user.name" -otsv
    $tenantIDname = Get-AzTenant -TenantId $pscontext.Tenant.Id | Select-Object Name
    $matchcheck = $true

    Write-Host "Checking if configs match"
    #Check and make sure Powershell and CLI configs match


    if ($pscontext.Account.id -ne $cluser) {
        $matchcheck = $false
    }elseif ($pscontext.Tenant.Id -ne $cltenant) {
        $matchcheck = $false
    }elseif ($pscontext.Subscription.Id -ne $clsub) {
        $matchcheck = $false
    }

    Write-Host "Writing some errors, if they exist"
    #Write Error information to screen
    If ($matchcheck) {
        Write-Host "INFO: Context configs match.  Verify below contexts are correct" -ForegroundColor DarkGreen -BackgroundColor White
        Write-Host ""
    }elseif ($false -eq $matchcheck) {
        Write-Warning "Powershell and AZ CLI configs do not match - run set-Myconfig and enter context information"
    }

    Write-Host "Write configs to screen"
    #Write Contexts to screen
    Write-Host "Current Powershell Connection" -BackgroundColor White -ForegroundColor DarkGreen
    Write-Host "Account =" $pscontext.Account.id -ForegroundColor DarkGreen
    Write-Host "TenantName =" $tenantIDname.Name -ForegroundColor DarkGreen
    Write-Host "TenantID =" $pscontext.Tenant.Id -ForegroundColor DarkGreen
    Write-Host "SubNName =" $pscontext.Subscription.Name -ForegroundColor DarkGreen
    Write-Host "SubID =" $pscontext.Subscription.Id -ForegroundColor DarkGreen

    Write-Host "Current AzureCLI Connection" -BackgroundColor White -ForegroundColor DarkGreen
    Write-Host "Account =" $cluser -ForegroundColor DarkGreen
    Write-Host "TenantName =" $cltenantname -ForegroundColor DarkGreen
    Write-Host "TenantID =" $cltenant -ForegroundColor DarkGreen
    Write-Host "SubName =" $clsubname -ForegroundColor DarkGreen
    Write-Host "SubID =" $clsub -ForegroundColor DarkGreen

}

#Export-ModuleMember -Function Get-MyContext


