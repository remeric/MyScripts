Get-ChildItem (Split-Path $script:MyInvocation.MyCommand.Path) -Filter '.PublicFunctions\*.ps1' -Recurse | ForEach-Object { 
    . $_.FullName 
    } 