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



function test-mymodule {
    get-powershellisadmin
    $mydevModules = Get-ChildItem .\Modules -Directory | Where-Object {$_.Name -Match "^My.*"}
    $path = "c:\temp\moduledevelopment"
    $pathEscaped = "c:\\temp\\moduledevelopment" #update to do programatically.
    if (!(test-path "$path")) {
        write-host "creating development folder"
        New-Item -Path $path -ItemType Directory
    }
    foreach ($module in $mydevModules) {
        Copy-Item $module "$path" -Recurse -Force
        $file = Get-Item "$path\$($module.Name)\*" | Where-Object {$_.Name -match "/*.psd1"}
        (Get-Content $file ) -replace "ModuleVersion = .*", "ModuleVersion = '0.0.0'" | Set-Content $file
        }
    $p = [Environment]::GetEnvironmentVariable("PSModulePath")
    if (!($p -match $pathEscaped)) {
    $p += ";$path"
    [Environment]::SetEnvironmentVariable("PSModulePath",$p)
    }
    start-sleep 1
    remove-module MyModestModule
    import-module MyModestModule -RequiredVersion 0.0.0
}


#Revert module to latest after done developing to use latest installed
function revert-mymodule {
    remove-module MyModestModule
    import-module MyModestModule
}