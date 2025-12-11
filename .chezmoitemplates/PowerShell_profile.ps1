$UserHome = if ($IsWindows) { $env:USERPROFILE } else { $env:HOME }
if (-not $UserHome) {
    $UserHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
}

$OhMyPoshConfig = Join-Path $UserHome 'ohmyposh.config.toml'
oh-my-posh init pwsh --config $OhMyPoshConfig | Invoke-Expression
