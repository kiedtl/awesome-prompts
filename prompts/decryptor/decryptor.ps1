$global:__errc = 0
$values = @("33","36","37","38","39","46","45","44","42","43","47","58","59","94","94","46","46","126","161","162","163","164","165","166","167","168","169","170","171","172","173","174","175","176","177","178","179","180","181","182","183","184","185","186","187")

function Test-Administrator {
    if ($PSVersionTable.Platform -eq 'Unix') {
        return (whoami) -eq 'root'
    } elseif ($PSVersionTable.Platform -eq 'Windows') {
        return $false #TO-DO: find out how to distinguish this one
    } else {
        return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    }
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

function Get-FullPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PathInfo]
        $dir
    )

    if ($dir.path -eq "$($dir.Drive.Name):\") {
        return "$($dir.Drive.Name):"
    }
    $path = $dir.path.Replace(($HOME),'~').Replace('\', '\')
    return $path
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
function Test-VirtualEnv {
    if ($env:VIRTUAL_ENV) {
        return $true
    }
    if ($Env:CONDA_PROMPT_MODIFIER) {
        return $true
    }
    return $false
}

function Get-VirtualEnvName {
    if ($env:VIRTUAL_ENV) {
        $virtualEnvName = ($env:VIRTUAL_ENV -split '\\')[-1]
        return $virtualEnvName
    } elseif ($Env:CONDA_PROMPT_MODIFIER) {
        [regex]::Match($Env:CONDA_PROMPT_MODIFIER, "^\((.*)\)").Captures.Groups[1].Value;
    }
}

$escapeChar = [char]27

function prompt {
	# Reset cursor position
	$postion = $host.UI.RawUI.CursorPosition
	$postion.X = 0
	$host.UI.RawUI.CursorPosition = $postion

	# Variables
	$__char = [system.text.encoding]::utf8.getstring((226,157,175))
	$__size = $host.UI.RawUI.BufferSize.Width.ToString()
	$__time = "[$([datetime]::now.tostring("HH:mm:ss"))]"
	$__cdir = Get-ShortPath -dir $pwd
	$lcmf = $global:error.Count -gt $global:__errc

	# Get hash of the previous command's first token
	$lrcm = "$^"
	$alg = [System.Security.Cryptography.HashAlgorithm]::Create(("SHA256"))
	$fs = [System.Text.Encoding]::UTF8.GetBytes($lrcm)
	try { $lrcm = ([string]::join('', ($alg.ComputeHash($fs) | % { $_.ToString('x2') }))).Substring(0,8) }
	finally { $alg.dispose() }

	# Check if the previous command failed,
	# and if it did, write the prmpt in darkred instead of blue color
	if ($lcmf) { $__color = 'darkred' } else { $__color = 'blue' }
	$global:__errc = $global:error.Count

	# Mimic the data decryption effect seen in the Sneakers movie.
	$rand = get-random -maximum 999 -setseed (get-random -setseed ([datetime]::now.tostring("HHmmssff")))
	$dest = -join (([text.encoding]::ascii.getbytes($lrcm)) | % { [char][int]($values[(((([int]$_) * $rand) - 97) % $values.Count)]) })
	if ((get-date -format "MM/dd").ToString() -eq "04/01") { $dest = [text.encoding]::utf8.getstring((32,32,40,226,140,144,226,151,145,95,226,151,145,41)) }
	$E = [char]27
	$postion = $host.UI.RawUI.CursorPosition
	$src = @("")
	0..10 | % {
		$src += -join ((33..48) + (58..64) + (91..96) + (123..126) + (161..187) | get-random -count 7 | % {[char]$_})	
	}
	write-host "$($src[5])" -f white -nonewline
	start-sleep -m 800
	write-host "`r         " -nonewline
	1..6 | % {
		$src | % {
			write-host "`r$_" -nonewline -f white
			start-sleep -m 10
		}
	}
	$i = 0
	$postion = $host.UI.RawUI.CursorPosition
	$postion.X = 0
	$host.UI.RawUI.CursorPosition = $postion
	0..8 | % {
		write-host $dest[$i] -nonewline -f yellow
		$postion.X = $i
		$host.UI.RawUI.CursorPosition = $postion
		$i++
		start-sleep -m 100
	}

	# Write the prompt.
	$postion.X = 8
	$host.UI.RawUI.CursorPosition = $postion

	write-host "$__char$__char$__char" -f $__color -nonewline

	# Write the directory to the right of the screen,
	# for some reason, as soon as the user starts to type,
	# the directory disappears.
	$postion = $host.UI.RawUI.CursorPosition
	$postion.X = ($__size - (($__cdir.Length) + 1))
	$host.UI.RawUI.CursorPosition = $postion
	write-host "$__cdir" -f $__color -nonewline

	$postion.X = 11
	$host.UI.RawUI.CursorPosition = $postion

	# Return a space.
	return " "
}
