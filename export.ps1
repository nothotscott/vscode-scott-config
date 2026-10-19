<#
.SYNOPSIS
    Pulls this machine's VS Code config back into the repo, to commit.
.DESCRIPTION
    The reverse of install.ps1: copies settings.json and keybindings.json from %APPDATA%\Code\User
    and rewrites extensions.txt from `code --list-extensions`. Review with `git diff` before
    committing. New extensions that aren't on Open VSX need their .vsix added to vsix\ by hand (see
    the README).
#>
$ErrorActionPreference = "Stop"
$repoDirectory = $PSScriptRoot
$userDirectory = Join-Path $env:APPDATA "Code\User"

foreach ($configFileName in "settings.json", "keybindings.json") {
    Copy-Item (Join-Path $userDirectory $configFileName) (Join-Path $repoDirectory "User\$configFileName") -Force
}
# No BOM and LF endings: install.sh reads this file too, and Set-Content in PowerShell 5.1 adds a BOM
$extensionIds = (code --list-extensions) -join "`n"
[System.IO.File]::WriteAllText((Join-Path $repoDirectory "extensions.txt"), "$extensionIds`n", (New-Object System.Text.UTF8Encoding $false))
git -C $repoDirectory status --short
