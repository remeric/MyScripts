#For setting dark mode for various OS level and application level items.

function set-myDarkMode {
    [CmdletBinding()]
    param (
        [bool]$darkmode = $true
        # [switch]$list = $false
    )

    write-debug "debug preference is $DebugPreference"

    # Read-Host "WARNING: Some programs must be close out to enabled dark mode, please be sure all your work is saved."

    #List of Programs
    $Programs = 
        "windowsSystem",
        "windowsApps",
        "notepadPlusPlus"

    # if ($list) {
    #     Write-Host "The following programs will enter dark mode upon running this function"
    #     Write-Host $Programs
        
    # }

    #Setting Variables based on Mode
    if ($DarkMode) {
        $int = 0
        $lightlevel = "Darkening"
        Write-Debug "Set int to $int and lightlevel to $lightlevel"
    } else {
        $int = 1
        $lightlevel = "Lighting"
        Write-Debug "Set int to $int and lightlevel to $lightlevel"
    }

    #Windows System
    Write-Host "$lightlevel Windows System"
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value $int -Type Dword -Force | out-null

    Write-Host "$lightlevel Windows Apps"
    #Windows Apps
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value $int -Type Dword -Force | out-null

    #Notepad++
    #Need to figure out why regex isn't working on my replace and use that to catch all scenarios
    if (Test-Path "$env:APPDATA\Notepad++\config.xml") {
        $config = Get-Content $env:APPDATA\Notepad++\config.xml
        if ($darkmode -And $config -match '"DarkMode" enable="no"') {
            Write-Host "$lightlevel notepad++"
            Write-Debug "DEBUG:Running section to change dark mode enable from no to yes in notepad++"
            $notepadplusplus = Get-Process | where-Object {$_.ProcessName -eq "notepad++"}
            foreach ($process in $notepadplusplus) {
                (Get-Process -Id $process.Id).CloseMainWindow()
            }
            sleep 1
            (Get-content $env:APPDATA\Notepad++\config.xml).Replace('"DarkMode" enable="no"', '<GUIConfig name="DarkMode" enable="yes"') | set-content $env:APPDATA\Notepad++\config.xml | out-null
            notepad++
        } elseif (!$darkmode -And $config -match '"DarkMode" enable="yes"') {
            Write-Host "$lightlevel notepad++"
            Write-Debug "DEBUG:Running section to change dark mode enable from yes to no in notepad++"
            $notepadplusplus = Get-Process | where-Object {$_.ProcessName -eq "notepad++"}
            foreach ($process in $notepadplusplus) {
                (Get-Process -Id $process.Id).CloseMainWindow()
            }
            sleep 1
            (Get-content $env:APPDATA\Notepad++\config.xml).Replace('"DarkMode" enable="yes"', '<GUIConfig name="DarkMode" enable="no"') | set-content $env:APPDATA\Notepad++\config.xml | out-null
            notepad++
        }
    } else {
        Write-Host "Notepad++ not installed or config file does not exist at $notepadplusplusconfig"
    }
}