function Update-MyModules {

$AsAdministrator = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains 'S-1-5-32-544'

if ($AsAdministrator -ne "True") {
    Throw "Please run powershell as administrator"
}

#Check for git
try {
    git --version
    if ($? -eq $false) {
        }
    }
    catch {
        Throw "Terminating, command requires git, please install git"
    }

#Check for Modules
If (Test-Path "$Env:ProgramFiles\WindowsPowerShell\Modules\My") {

} else 
{
    Throw "Module doesn't exist in path $Env:ProgramFiles\WindowsPowerShell\Modules\, either module is not installed or module is installed in a path not supported by this command."
}

#Check for Previous update files and delete them
If (Test-Path "$Env:SystemDrive\temp\MyModule\My") {
    Write-Warning "Update folder exists - you don't need this folder unless you saved personal stuff there for some wired reason or want to keep the old update"
    $confirmation = Read-Host "Update folder $Env:SystemDrive\temp\MyModule\My exists, to delete folder and download latest update folder type 'yes'"
        if ($confirmation -ne 'yes') {
            Throw "Aborting due to user input"
        } else {
            Write-Host "Removing $Env:SystemDrive\temp\MyModule\My"
            Remove-item $Env:SystemDrive\temp\MyModule\My -Recurse
            Write-Host "Removing $Env:SystemDrive\temp\MyModule\My.Logins"
            Remove-item $Env:SystemDrive\temp\MyModule\My.Logins -Recurse
        }
}

#Install
Write-Host "Creating Directory"
New-Item -Path "$Env:SystemDrive\temp\MyModule" -Name "My" -ItemType "directory"

Write-Host "Downloading and unzipping files"
Invoke-WebRequest -Uri "https://github.com/remeric/MyScripts/archive/refs/heads/main.zip" -OutFile "$Env:SystemDrive\temp\MyModule\My\My.zip"
Expand-Archive -Path "$Env:SystemDrive\temp\MyModule\My\My.zip" -DestinationPath "$Env:SystemDrive\temp\MyModule\My"

Write-Host "Deleting old module version"
Remove-Item "$Env:ProgramFiles\WindowsPowerShell\Modules\My" -Recurse

Write-Host "Installing (copying) new module version"
Copy-item -path "$Env:SystemDrive\temp\MyModule\My\MyScripts-main\Modules\*" "$Env:ProgramFiles\WindowsPowerShell\Modules" -Recurse

Write-Host "Cleaning Up Files"
Remove-item $Env:SystemDrive\temp\MyModule\My -Recurse

}