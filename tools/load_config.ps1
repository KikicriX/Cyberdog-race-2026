$CyberDogRepoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$preferredConfig = Join-Path $CyberDogRepoRoot "local\config\cyberdog.ps1"
$legacyConfig = Join-Path $PSScriptRoot "config.ps1"

if (Test-Path -LiteralPath $preferredConfig -PathType Leaf) {
    $CyberDogConfigPath = $preferredConfig
} elseif (Test-Path -LiteralPath $legacyConfig -PathType Leaf) {
    $CyberDogConfigPath = $legacyConfig
    Write-Warning "Using legacy tools/config.ps1. Move it to local/config/cyberdog.ps1 when convenient."
} else {
    throw "CyberDog config not found. Copy tools/config.example.ps1 to local/config/cyberdog.ps1 and edit it."
}

. $CyberDogConfigPath

if (-not $LocalProgramDir) {
    $LocalProgramDir = Join-Path $CyberDogRepoRoot "program"
}
if (-not $LogDir) {
    $LogDir = Join-Path $CyberDogRepoRoot "local\logs"
}
