Publishing a Module:
- Pre-Reqs:
    - Login to Powershell gallery and generate an API key under your profile first
    - Install Nuget - winget install microsoft.nuget #Might not be necessary, need to test, just getting the latest
    - Install PowershellGet Latest Version - Import-Module PowershellGet -Force #do this as admin, I had to add force because 1.0.0 was already installed, probably from the first publish attempt

- Run from powershell 5.X :
Publish-Module -Path .\Modules\MyModestModule -NuGetApiKey $apikey

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
- Generating module manifests:
    https://docs.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest?view=powershell-7.2
- Module Installation Rules:
    https://learn.microsoft.com/en-us/powershell/scripting/developer/module/installing-a-powershell-module?view=powershell-7.4#rules-for-installing-modules

ToDo:
- Sign Package

Testing:
    Test-ModuleManifest .\Modules\MyModestModule\MyModestModule.psd1
    Invoke-ScriptAnalyzer .\Modules\MyModestModule\MyModestModule.psm1
    Install-Module -Name Pester -Force
    https://github.com/Pester/Pester
    psPrivateGallery (https://github.com/PowerShell/PSPrivateGallery) - no longer maintained

Best Practices:
https://learn.microsoft.com/en-us/powershell/gallery/concepts/publishing-guidelines?view=powershellget-3.x