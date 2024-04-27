Get-ChildItem (Split-Path $script:MyInvocation.MyCommand.Path) -Filter '*.ps1' -Recurse | ForEach-Object {
    . $_.FullName
    }