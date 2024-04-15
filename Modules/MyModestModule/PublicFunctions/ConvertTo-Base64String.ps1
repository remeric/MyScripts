##Modified from Vrushal Talegaonkar's personal script - thanks Vrushal!
<#
    .Description
     Converts a file into a base64 string.  Enter file path after command.
#>

function ConvertTo-MyBase64String {

    Param (         
      [Parameter(Mandatory)]         
      [ValidateScript({                 
        if (-Not ($_ | Test-Path) ) {                     
          throw "The file or folder $_ does not exist"                 
        }                
        if (-Not ($_ | Test-Path -PathType Leaf) ) {                     
          throw "The Path argument must be a file. Folder paths are not allowed."                 
        }                
        return $true             
      })]        
      [string] $Path     
    )  

    $fileContentBytes = get-content $Path -AsByteStream
    $Base64Cert = [System.Convert]::ToBase64String($fileContentBytes)
    $Base64Cert
  }