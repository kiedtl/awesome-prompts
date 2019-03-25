#!/usr/bin/env pwsh

# ----- HELPER FUNCTIONS -------
# stolen from Oh-My-Posh

function Get-Drive {
    param(
        [Parameter(Mandatory = $true)]
        [System.Object]
        $dir
    )

    $provider = (Get-Item $dir.path -Force).PSProvider.Name

    if($provider -eq 'FileSystem') {
        $homedir = ($HOME.TrimEnd('/','\'))
        if($dir.Path.StartsWith($homedir)) {
            return '~'
        }
        elseif($dir.Path.StartsWith('Microsoft.PowerShell.Core')) {
            $parts = $dir.Path.Replace('Microsoft.PowerShell.Core\FileSystem::\\','').Split('\')
            return "$($parts[0])$($sl.PromptSymbols.PathSeparator)$($parts[1])$($sl.PromptSymbols.PathSeparator)"
        }
        else {
            $root = $dir.Drive.Name
            if($root) {
                return $root
            }
            else {
                return $dir.Path.Split(':\')[0] + ':'
            }
        }
    }
    else {
        return $dir.Drive.Name
    }
}

function Get-ShortPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PathInfo]
        $dir
    )

    $provider = ((Get-Item $dir.path -Force).PSProvider.Name)

    if($provider -eq 'FileSystem') {
        $result = @()
        $currentDir = Get-Item $dir.path -Force

        while( ($currentDir.Parent) -And ($currentDir.FullName -ne (($HOME.TrimEnd('/','\')))) ) {
            if( ( (Test-Path -Path "$($currentDir.FullName)\.git") -Or (Test-Path -Path "$($dir.FullName)\.hg") -Or (Test-Path -Path "$($dir.FullName)\.svn")) -Or ($result.length -eq 0) ) {
                $result = ,$currentDir.Name + $result
            }
            else {
                $result = ,'..' + $result
            }

            $currentDir = $currentDir.Parent
        }
        $shortPath =  $result -join '\'
        if ($shortPath) {
            $drive = (Get-Drive -dir $dir)
            return "${drive}\$shortPath"
        }
        else {
            if ($dir.path -eq (($HOME.TrimEnd('/','\')))) {
                return '~'
            }
            return "$($dir.Drive.Name):"
        }
    }
    else {
        return $dir.path.Replace((Get-Drive -dir $dir), '')
    }
}

function Get-ComputerName {
    if (Test-PsCore -and $PSVersionTable.Platform -ne 'Windows') {
        if ($env:NAME) {
            return $env:NAME
        } else {
            return (uname -n)
        }
    }
    return $env:COMPUTERNAME
}

function prompt {
    # variables
    $host = get-computername
    $user = [System.Environment]::UserName
    $cwdr = get-shortpath
    
    # chars
    $dash = [text.encoding]::getstring((226,148,128))

    # print a newline
    write-host "" -nonewline
    
    # escape character
    $E = [char]0x1B
    
    # set color
    write-host "$E[0;31m" -nonewline
    
    # Add ┌─ character
    $bracket1 = [text.encoding]::getstring((226,148,140,226,148,128))
    write-host "${bracket1}" -nonewline
    
    # write [✗]─ if previous command failed
    $cfailed = [text.encoding]::getstring((91,226,156,151,93,226,148,128))
    if ($lastexitcode -ne 0) {
        write-host "${cfailed}" -nonewline
    }
    
    # write the rest of the prompt
    $prompt2 = [text.encoding]::getstring((226,148,148,226,148,128,226,148,128,226,149,188))
    write-host "${E}[0;39m${user}${E}[01;33m@${E}[01;96m${host}" -nonewline
    write-host "${E}[0;31m]${dash}[${E}[0;32m${cwdr}${E}[0;31m]" -nonewline
    write-host "`n${E}[0;31m${prompt} ${E}[0m${E}[01;33m`$${E}[0m "
}
