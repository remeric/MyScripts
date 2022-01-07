<#
    .Description
    Verify the Account, Tenant, and Sub being used for Azure CLI and AZ Powershell, and verify they match.
#>

function Get-MyContext {

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
    
    #Set variables
    $pscontext = Get-AzContext
    $clisub = az account show --query "id" -otsv
    $clisubname = az account subscription show --subscription-id $clisub --query "displayName" -otsv --only-show-errors
    $clitenant = az account show --query "tenantId" -otsv
    $clitenantname = az account show --query "name" -otsv
    $cliuser = az account show --query "user.name" -otsv
    $tenantIDname = Get-AzTenant -TenantId $pscontext.Tenant.Id | select Name
    $matchcheck = $null

    #Check and make sure Powershell and CLI configs match
    if ($pscontext.Account.id -ne $cliuser) {
        $matchcheck = $false
        break
    }elseif ($pscontext.Tenant.Id -ne $clitenant) {
        $matchcheck = $false
        break
    }elseif ($pscontext.Subscription.Id -ne $clisub) {
        $matchcheck = $false
        break
    }else {
        $matchcheck = $true
    }

    #Write Error information to screen
    If ($matchcheck) {
        Write-Host "INFO: Context configs match.  Verify below contexts are correct" -ForegroundColor DarkGreen -BackgroundColor White
        Write-Host ""
    }elseif ($false -eq $matchcheck) {
        Throw "Powershell and cLI configs do not match - run set-Myconfig and enter context information"
    }else {
        Write-Warning "Checks failed.  Verify Powershell and CLI configs listed below match, if not run set-Myconfig and enter context information"
    }
    
    #Write Contexts to screen
    Write-Host "Current Powershell Connection" -BackgroundColor White -ForegroundColor DarkGreen
    Write-Host "Account =" $pscontext.Account.id -ForegroundColor DarkGreen
    Write-Host "TenantName =" $tenantIDname.Name -ForegroundColor DarkGreen
    Write-Host "TenantID =" $pscontext.Tenant.Id -ForegroundColor DarkGreen
    Write-Host "SubNName =" $pscontext.Subscription.Name -ForegroundColor DarkGreen
    Write-Host "SubID =" $pscontext.Subscription.Id -ForegroundColor DarkGreen

    Write-Host "Current AzureCLI Connection" -BackgroundColor White -ForegroundColor DarkGreen
    Write-Host "Account =" $cliuser -ForegroundColor DarkGreen
    Write-Host "TenantName =" $clitenantname -ForegroundColor DarkGreen
    Write-Host "TenantID =" $clitenant -ForegroundColor DarkGreen
    Write-Host "SubName =" $clisubname -ForegroundColor DarkGreen
    Write-Host "SubID =" $clisub -ForegroundColor DarkGreen

}

Export-ModuleMember -Function Get-MyContext




