#!/usr/bin/env pwsh

# ----- HELPER FUNCTIONS -------
# stolen from Oh-My-Posh

function Test-PsCore {
    return $PSVersionTable.PSVersion.Major -gt 5
}

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
    $hostname = get-computername
    $username = [System.Environment]::UserName
    $cwdr = get-shortpath $(pwd)

    # chars
    $dash = [text.encoding]::UTF8.getstring((226,148,128))

    # print a newline
    write-host "`n" -nonewline

    # escape character
    $E = [char]0x1B

    # Add ┌─ character
    $bracket1 = [text.encoding]::UTF8.getstring((226,148,140,226,148,128))
    write-host "${bracket1}[" -nonewline -f Gray

    # write [✗]─ if previous command failed
    $lcmf = $global:error.Count -gt $global:_errc
    if ($lcmf) {
        write-host "${cfailed}" -nonewline
    }
	  $global:_errc = $global:error.Count

    # write the rest of the prompt
    $prompt2 = [text.encoding]::UTF8.getstring((226,148,148,226,148,128,226,148,128,226,149,188))
    write-host "${E}[0;39m${username}${E}[01;33m@${E}[01;96m${hostname}" -nonewline
    write-host "${E}[0;31m]${dash}[${E}[0;32m${cwdr}${E}[0;31m]" -nonewline
    write-host "`n${E}[0;31m${prompt2} ${E}[0m${E}[01;33m`$${E}[0m" -nonewline

    return " "
}
