##Modified from Vrushal Talegaonkar's personal script - thanks Vrushal!
<#
    .Description
     Converts a file into a Compressed base64 string in case the regular ConvertTo-Base64String is too long, for instance an Azure ADO string field limit.  Enter file path after command.
#>

function ConvertTo-MyBase64StringCompressed {     
    [CmdletBinding()]     
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
    
    $fileBytes = [System.IO.File]::ReadAllBytes($Path)     
    [System.IO.MemoryStream] $memoryStream = New-Object System.IO.MemoryStream     
    $gzipStream = New-Object System.IO.Compression.GzipStream $memoryStream, ([IO.Compression.CompressionMode]::Compress)     
    $gzipStream.Write($fileBytes, 0, $fileBytes.Length)     
    $gzipStream.Close()     
    $memoryStream.Close()     
    $compressedFileBytes = $memoryStream.ToArray()     
    $encodedCompressedFileData = [Convert]::ToBase64String($compressedFileBytes)     
    $gzipStream.Dispose()     
    $memoryStream.Dispose()     
    return $encodedCompressedFileData 
  }