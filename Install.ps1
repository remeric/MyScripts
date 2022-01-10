#Run this script from your machine to install the Module for the first time

#Removing old installation folder in case this was tried once before and failed and didn't clean up files
#Or in case you happen to have a folder named "$Env:SystemDrive\temp\MyModule\My"
If (Test-Path "$Env:SystemDrive\temp\MyModule\My") {
    Write-Warning "If this is your first install, why do you have the install/update folder?  Verify the folder has no personal stuff"
    $confirmation = Read-Host "Install folder $Env:SystemDrive\temp\MyModule\My exists, to delete folder and download latest update folder type 'yes'"
        if ($confirmation -ne 'yes') {
            Throw "Aborting due to user input"
        } else {
            Write-Host "Removing $Env:SystemDrive\temp\MyModule\My"
            Remove-item $Env:SystemDrive\temp\MyModule\My -Recurse
        }
}

Write-Host "Creating Directory"
New-Item -Path "$Env:SystemDrive\temp\MyModule" -Name "My" -ItemType "directory"

Write-Host "Downloading and unzipping files"
Invoke-WebRequest -Uri "https://github.com/remeric/MyScripts/archive/refs/heads/main.zip" -OutFile "$Env:SystemDrive\temp\MyModule\My\My.zip"
Expand-Archive -Path "$Env:SystemDrive\temp\MyModule\My\My.zip" -DestinationPath "$Env:SystemDrive\temp\MyModule\My"

#Just in case you have installed it before and have an old version
Write-Host "Deleting old module version"
If (Test-Path "$Env:ProgramFiles\WindowsPowerShell\Modules\My") {
Remove-Item "$Env:ProgramFiles\WindowsPowerShell\Modules\My" -Recurse 
Remove-Item "$Env:ProgramFiles\WindowsPowerShell\Modules\My.Logins" -Recurse
}

Write-Host "Installing (copying) new module version"
Copy-item -path "$Env:SystemDrive\temp\MyModule\My\MyScripts-main\Modules\*" "$Env:ProgramFiles\WindowsPowerShell\Modules" -Recurse

Write-Host "Cleaning Up Files"
Remove-item $Env:SystemDrive\temp\MyModule\My -Recurse