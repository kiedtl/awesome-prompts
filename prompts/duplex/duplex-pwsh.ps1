#!/usr/bin/env pwsh

# ----- HELPER FUNCTIONS -------
# stolen from Oh-My-Posh

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
    $cwdr = split-path $PWD -leaf
    
    # chars
    $dash = [text.encoding]::UTF8.getstring((226,148,128))

    # print a newline
    write-host "" -nonewline
    
    # escape character
    $E = [char]0x1B
    
    # set color
    write-host "$E[0;31m" -nonewline
    
    # Add ┌─ character
    $bracket1 = [text.encoding]::UTF8.getstring((226,148,140,226,148,128))
    write-host "${bracket1}" -nonewline
    
    # write [✗]─ if previous command failed
    $cfailed = [text.encoding]::UTF8.getstring((91,226,156,151,93,226,148,128))
    if ($lastexitcode -ne 0) {
        write-host "${cfailed}" -nonewline
    }
    
    # write the rest of the prompt
    $prompt2 = [text.encoding]::UTF8.getstring((226,148,148,226,148,128,226,148,128,226,149,188))
    write-host "${E}[0;39m${username}${E}[01;33m@${E}[01;96m${hostname}" -nonewline
    write-host "${E}[0;31m]${dash}[${E}[0;32m${cwdr}${E}[0;31m]" -nonewline
    write-host "`n${E}[0;31m${prompt2} ${E}[0m${E}[01;33m`$${E}[0m" -nonewline
    
    return " "
}
