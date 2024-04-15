########################################################

# Useful functions during the development of My Module #

########################################################

#Test if powershell is running as an administrator
function get-powershellisadmin {
    $AsAdministrator = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'

    if ($AsAdministrator -ne "True") {
        Throw "Please run powershell as administrator"
    }
    else {
        write-host "verified powershell is running as admin"
    }
}

#Clear out all instances of the module
function clean-mymodule {
    get-powershellisadmin
    $mymodules = get-module | Where-Object {$_.name -Match "^My.*"}
    Foreach ($module in $mymodules) {
        remove-module $module
    }
    $paths = [Environment]::GetEnvironmentVariable("PSModulePath") -split ";"
    foreach ($path in $paths) {
        Get-ChildItem -Path $path -Directory | Where-Object {$_.Name -Match "^My.*"} | Remove-Item -Recurse
    }
}