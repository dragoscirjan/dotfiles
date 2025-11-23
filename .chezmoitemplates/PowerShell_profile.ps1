$OhMyPoshConfig = Join-Path $env:USERPROFILE 'ohmyposh.config.toml'
oh-my-posh init pwsh --config $OhMyPoshConfig | Invoke-Expression
