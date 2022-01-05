function set-MyContext {
    Param (
        [Parameter(Mandatory = $true
            )]
        [string] $user = ${user},

        [Parameter(Mandatory = $true
            )]
        [string] $tenant = ${tenant},

        [Parameter(Mandatory = $true
            )]
        [string] $subscription = ${subscription}

        )

    Write-Host ""
    Write-Host "Verifying Azure CLI and PS are even logged in..."

    #Verify Azure CLI is logged in, and if not log it in
    #Try/Catch setup to supress error as AZ CLI can't natively suppress errors
    $ErrorActionPreference = "stop"
    try {
        az account show --output none --only-show-errors
        if ($? -eq $false) {
            }
        }
        catch {
            Write-Warning "AZ CLI not logged in, logging in now - browser should open with login prompt"
            az Login --tenant $tenant --only-show-errors --output none
        }
    $ErrorActionPreference = "Continue"

    #Verify Az Powershell module is Logged in to ANYTHING
    $azcontext = Get-AzContext
    if ($null -eq $azcontext) {
        Write-Warning "AZ Powershell not logged in, logging in now - watch for GUI prompt"
        Write-Warning "Verify GUI prompt is not behind an app for some reason..."
        Connect-AzAccount -Tenant $tenant -Subscription $subscription
    }

    #Get Current Account, Tenant, and Sub for PS and CLI
    $pscontext = Get-AzContext
    $clisub = az account show --query "id" -otsv
    $clitenant = az account show --query "tenantId" -otsv
    $cliuser = az account show --query "user.name" -otsv

    Write-Host "Checking to see if any context items need set....."

    #Powershell Commands
        #Check PS Account
        if ($pscontext.Account.id -ne $user) {
            write-Host "Log: Logging out PS account " $pscontext.Account.id " and logging in $user"
            Connect-AzAccount -Tenant $tenant -Subscription $subscription | out-null
        }
        Else {
            Write-Host "Log: PS User " $pscontext.Account.id " already logged in"
        }

        #Check PS Tenant
        if ($pscontext.Tenant.id -ne $tenant) {
            Write-Host "Log: Setting PS Tenant from " $pscontext.Tenant.id " to" $tenant
            Set-AzContext -Tenant $tenant -Subscription $subscription | out-null
        }
        Else {
            write-host "Log: PS Tenant " $pscontext.Tenant.id " already set"
        }

        #check PS Subscription
        if ($pscontext.subscription.id -ne $subscription) {
            Write-Host "Log: Changing from PS subscription " $pscontext.Subscription.id " to" $subscription
            Set-AzContext -Tenant $tenant -Subscription $subscription | out-null
        }
        else {
            Write-Host "Log: PS Subscription " $pscontext.Subscription.id " already set"
        }

    #CLI Commands
        #Check CLI Account
        if ($cliuser -ne $user) {
            write-host "Log: Logging out CLI account " $cliuser " and logging in $user"
            az Login --tenant $tenant --only-show-errors --output none
        }
        Else {
            write-host "Log: CLI User " $cliuser " already logged in"
        }

        #Check CLI Tenant
        if ($clitenant -ne $tenant) {
            Write-Host "Log: Setting CLI Tenant from " $clitenant " to" $tenant
            az Login --tenant $tenant --output none --only-show-errors
        }
        Else {
            write-host "Log: CLI Tenant " $clitenant " already set"
        }

        #check CLI Subscription
        if ($clisub -ne $subscription) {
            Write-Host "Log: Changing from CLI subscription " $clisub " to" $subscription
            az account set --subscription $subscription --output none --only-show-errors
        }
        else {
            Write-Host "Log: CLI Subscription " $clisub " already set"
        }

    Write-Host ""
    Write-Host "Verifying all contexts were set correctly...."

    #Verify Everything was set correctly and output current logins

        $pscontext = Get-AzContext
        $clisub = az account show --query "id" -otsv
        $clitenant = az account show --query "tenantId" -otsv
        $cliuser = az account show --query "user.name" -otsv
        $tenantname = Get-AzTenant $tenant | select Name

    #Powershell Commands
        #Check PS Account
        if ($pscontext.Account.id -ne $user) {
            Throw "Powershell User Login Failed, Terminating"
        }

        #Check PS Tenant
        if ($pscontext.Tenant.id -ne $tenant) {
            Throw "Powershell Tenant Context Set Failed, Terminating"
        }

        #check PS Subscription
        if ($pscontext.subscription.id -ne $subscription) {
            Throw "Powershell Subscription Context Set Failed, Terminating"
        }

        #Check CLI Account
        if ($cliuser -ne $user) {
            Throw "AZ CLI User Login Failed, Terminating"
        }

        #Check CLI Tenant
        if ($clitenant -ne $tenant) {
            Throw "CLI Tenant Context Set Failed, Terminating"
        }

        #check CLI Subscription
        if ($clisub -ne $subscription) {
            Throw "CLI Subscription Context Set Failed, Terminating"
        }

    Write-Host "Current Connection Information" -BackgroundColor White -ForegroundColor DarkGreen
    Write-Host "Account =" $pscontext.Account.id -ForegroundColor DarkGreen
    Write-Host "TenantName =" $tenantname -ForegroundColor DarkGreen
    Write-Host "TenantID =" $pscontext.Tenant.Id -ForegroundColor DarkGreen
    Write-Host "SubNName =" $pscontext.Subscription.Name -ForegroundColor DarkGreen
    Write-Host "SubID =" $pscontext.Subscription.Id -ForegroundColor DarkGreen

}


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
    $tenantname = Get-AzTenant -TenantId $pscontext.Tenant.Id | select Name
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
    Write-Host "TenantName =" $tenantname.Name -ForegroundColor DarkGreen
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

Export-ModuleMember -Function Set-MyContext
Export-ModuleMember -Function Get-MyContext




