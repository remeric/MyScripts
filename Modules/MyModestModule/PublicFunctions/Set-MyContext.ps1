<#
    .Description
    This cmdlet allows you to set your context simultanesouly for both the Azure CLI and Azure Powershell, and will then verify that the context is correct.  This is helpful when needing to switch quickly between Accounts, Tennants or Subscriptions.
    Additionally you can add variables to your Powershell profile to automatically load ID's like tenant or subcription, so you don't have to remember them and can reference the vairable.  IF you use Powershell 5 AND 7 be sure to load it in the profile for both.
    Example:  $myusernamecompanyname = "accountname" $mytennantcompanyname = "TenantID" $mysubscriptioncompanyname = "SubcriptionID"
#>

function set-MyContext
    {


    Param (
        [Parameter(Mandatory = $true
            )]
        [string] $user = ${user},

        [Parameter(Mandatory = $true
            )]
        [string] $tenantID = ${tenantID},

        [Parameter(Mandatory = $true
            )]
        [string] $subscriptionID = ${subscriptionID}

        )

    write-output ""
    write-output "Verifying Azure CLI and PS are even logged in..."

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
            az Login --tenant $tenantID --only-show-errors --output none
        }
    $ErrorActionPreference = "Continue"

    #Verify Az Powershell module is Logged in to ANYTHING
    $azcontext = Get-AzContext
    if ($null -eq $azcontext) {
        Write-Warning "AZ Powershell not logged in, logging in now - watch for GUI prompt"
        Write-Warning "Verify GUI prompt is not behind an app for some reason..."
        Connect-AzAccount -Tenant $tenantID -Subscription $subscriptionID
    }

    #Get Current Account, Tenant, and Sub for PS and CLI
    $pscontext = Get-AzContext
    $clsub = az account show --query "id" -otsv
    $cltenant = az account show --query "tenantId" -otsv
    $cluser = az account show --query "user.name" -otsv

    write-output "Checking to see if any context items need set....."

    #Powershell Commands
        #Check PS Account
        if ($pscontext.Account.id -ne $user) {
            write-output "Log: Logging out PS account " $pscontext.Account.id " and logging in $user"
            Connect-AzAccount -Tenant $tenantID -Subscription $subscriptionID | out-null
        }
        Else {
            write-output "Log: PS User " $pscontext.Account.id " already logged in"
        }

        #Check PS Tenant
        if ($pscontext.Tenant.id -ne $tenantID) {
            write-output "Log: Setting PS Tenant from " $pscontext.Tenant.id " to" $tenantID
            Set-AzContext -Tenant $tenantID -Subscription $subscriptionID | out-null
        }
        Else {
            write-output "Log: PS Tenant " $pscontext.Tenant.id " already set"
        }

        #check PS Subscription
        if ($pscontext.subscription.id -ne $subscriptionID) {
            write-output "Log: Changing from PS subscription " $pscontext.Subscription.id " to" $subscriptionID
            Set-AzContext -Tenant $tenantID -Subscription $subscriptionID | out-null
        }
        else {
            write-output "Log: PS Subscription " $pscontext.Subscription.id " already set"
        }

    #CLI Commands
        #Check CLI Account
        if ($cluser -ne $user) {
            write-output "Log: Logging out CLI account " $cluser " and logging in $user"
            az Login --tenant $tenantID --only-show-errors --output none
        }
        Else {
            write-output "Log: CLI User " $cluser " already logged in"
        }

        #Check CLI Tenant
        if ($cltenant -ne $tenantID) {
            write-output "Log: Setting CLI Tenant from " $cltenant " to" $tenantID
            az Login --tenant $tenantID --output none --only-show-errors
        }
        Else {
            write-output "Log: CLI Tenant " $cltenant " already set"
        }

        #check CLI Subscription
        if ($clsub -ne $subscriptionID) {
            write-output "Log: Changing from CLI subscription " $clsub " to" $subscriptionID
            az account set --subscription $subscriptionID --output none --only-show-errors
        }
        else {
            write-output "Log: CLI Subscription " $clsub " already set"
        }

    write-output ""
    write-output "Verifying all contexts were set correctly...."

    #Verify Everything was set correctly and output current logins

        $pscontext = Get-AzContext
        $clsub = az account show --query "id" -otsv
        $cltenant = az account show --query "tenantId" -otsv
        $cluser = az account show --query "user.name" -otsv
        $tenantIDname = Get-AzTenant $tenantID | select Name

    #Powershell Commands
        #Check PS Account
        if ($pscontext.Account.id -ne $user) {
            Throw "Powershell User Login Failed, Terminating"
        }

        #Check PS Tenant
        if ($pscontext.Tenant.id -ne $tenantID) {
            Throw "Powershell Tenant Context Set Failed, Terminating"
        }

        #check PS Subscription
        if ($pscontext.subscription.id -ne $subscriptionID) {
            Throw "Powershell Subscription Context Set Failed, Terminating"
        }

        #Check CLI Account
        if ($cluser -ne $user) {
            Throw "AZ CLI User Login Failed, Terminating"
        }

        #Check CLI Tenant
        if ($cltenant -ne $tenantID) {
            Throw "CLI Tenant Context Set Failed, Terminating"
        }

        #check CLI Subscription
        if ($clsub -ne $subscriptionID) {
            Throw "CLI Subscription Context Set Failed, Terminating"
        }

    write-output "Current Connection Information" -BackgroundColor White -ForegroundColor DarkGreen
    write-output "Account =" $pscontext.Account.id -ForegroundColor DarkGreen
    write-output "TenantName =" $tenantIDname -ForegroundColor DarkGreen
    write-output "TenantID =" $pscontext.Tenant.Id -ForegroundColor DarkGreen
    write-output "SubNName =" $pscontext.Subscription.Name -ForegroundColor DarkGreen
    write-output "SubID =" $pscontext.Subscription.Id -ForegroundColor DarkGreen

}




