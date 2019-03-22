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

	$dir = get-location
	$folder = split-path $dir -leaf
	$spath = get-shortpath $dir
	$width = $host.UI.RawUI.BufferSize.Width.ToString()
	
	if ($dir.ToString() -eq $HOME) { $folder = "~" }

	write-host "{ $folder }" -nonewline -f cyan
	write-host " $([char]187)" -nonewline -f magenta

	# Write the directory to the right of the screen
	$postion = $host.UI.RawUI.CursorPosition
	$postion.X = (($width) - ((($spath).Length) + 1))
	$host.UI.RawUI.CursorPosition = $postion
	write-host "$spath" -f cyan -nonewline

	$postion.X = ($folder.Length + 6)
	$host.UI.RawUI.CursorPosition = $postion
	
	return " "
}