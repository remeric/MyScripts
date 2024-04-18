Publishing a Module:
- Pre-Reqs:
    - Login to Powershell gallery and generate an API key under your profile first
    - Install Nuget - winget install microsoft.nuget #Might not be necessary, need to test, just getting the latest
    - Install PowershellGet Latest Version - Import-Module PowershellGet -Force #do this as admin, I had to add force because 1.0.0 was already installed, probably from the first publish attempt

- Run from powershell 5.X :
    - $apikey = Read-Host "enter API key" -AsSecureString
    - Publish-Module -Path .\Modules\MyModestModule -NuGetApiKey $apikey

Manifests:
- New-ModuleManifest -Path .pds1path
- Test-ModuleManifest -Path .pds1path

PS Module Path:
- View all module paths
    - $env:PSModulePath -split ';'
- add a module path:
    - $p = [Environment]::GetEnvironmentVariable("PSModulePath")
    - $p += "$HOME\Documents\WindowsPowerShell\Modules"
    - [Environment]::SetEnvironmentVariable("PSModulePath",$p)

Helpful Links
- Creating script module: https://www.scriptrunner.com/en/blog/building-your-first-powershell-module/
- creating private repository https://scriptingchris.tech/2021/08/31/how-to-setup-a-private-powershell-repository/
- Generating module manifests: https://docs.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest?view=powershell-7.2
- Module Installation Rules: https://learn.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.4#rules-for-installing-modules

ToDo:
- Sign Package