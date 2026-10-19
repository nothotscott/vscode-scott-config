<#
.SYNOPSIS
    Applies this repo's VS Code config on Windows: settings, keybindings and extensions.
.DESCRIPTION
    Copies User\*.json over %APPDATA%\Code\User (the files it replaces are backed up next to them as
    *.bak), installs the backed-up .vsix files in vsix\, then every extension in extensions.txt.
    Extensions already installed are skipped by VS Code. Re-run any time; it only adds.
.PARAMETER SkipExtensions
    Only copy the settings and keybindings.
#>
param(
    [switch]$SkipExtensions
)

$ErrorActionPreference = "Stop"
$repoDirectory = $PSScriptRoot
$userDirectory = Join-Path $env:APPDATA "Code\User"

New-Item -ItemType Directory -Force $userDirectory | Out-Null
foreach ($configFile in Get-ChildItem (Join-Path $repoDirectory "User") -File) {
    $targetPath = Join-Path $userDirectory $configFile.Name
    if (Test-Path $targetPath) {
        Copy-Item $targetPath "$targetPath.bak" -Force
    }
    Copy-Item $configFile.FullName $targetPath -Force
    Write-Host "Copied $($configFile.Name)"
}

if ($SkipExtensions) {
    return
}

# The .vsix files first: they aren't on Open VSX, and some aren't reliably on the marketplace either
foreach ($vsixFile in Get-ChildItem (Join-Path $repoDirectory "vsix") -Filter *.vsix) {
    code --install-extension $vsixFile.FullName
}
foreach ($extensionId in Get-Content (Join-Path $repoDirectory "extensions.txt")) {
    if ([string]::IsNullOrWhiteSpace($extensionId)) {
        continue
    }
    code --install-extension $extensionId
}
