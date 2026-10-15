# Windows, WSL, and WezTerm

The Linux setup configures files inside Ubuntu. WezTerm and its fonts run on Windows, so they need a separate host-side setup. These steps use PowerShell and assume the repository is at `~/dotfiles` inside the WSL distribution; adjust that path in the commands if you cloned it elsewhere.

## Select the Ubuntu Distribution

In PowerShell, list the registered distributions and choose the exact Ubuntu name:

```powershell
wsl.exe --list --verbose
$Distro = 'Ubuntu-24.04' # Replace with the exact name shown above.
wsl.exe --set-default $Distro
```

The WezTerm config launches `wsl.exe` without `-d`, so it uses the distribution selected as the WSL default and starts in the Linux user's home directory. This avoids pinning the config to a particular Ubuntu release or Linux username.

## Copy the WezTerm Config

Install WezTerm for Windows, then copy the repo config to the Windows WezTerm config location:

```powershell
$ConfigSource = (wsl.exe -d $Distro --exec sh -lc 'wslpath -w "$HOME/dotfiles/.wezterm.lua"').Trim()
if ($LASTEXITCODE -ne 0) { throw 'Could not locate .wezterm.lua in the selected WSL distribution.' }
Copy-Item -LiteralPath $ConfigSource -Destination (Join-Path $env:USERPROFILE '.wezterm.lua') -Force
```

Restart WezTerm after copying. Its default window opens the selected WSL distribution. The launch menu also includes an `Ubuntu WSL (default distribution)` entry, plus PowerShell options. This config is for WezTerm; Windows Terminal uses a separate settings file and profile system.

## Install the Fonts on Windows

The repository includes FiraCode Nerd Font files. Copy them to a temporary Windows folder and open that folder:

```powershell
$FontSource = (wsl.exe -d $Distro --exec sh -lc 'wslpath -w "$HOME/dotfiles/fonts"').Trim()
if ($LASTEXITCODE -ne 0) { throw 'Could not locate the dotfiles fonts directory.' }
$FontStage = Join-Path $env:TEMP 'dotfiles-fonts'
New-Item -ItemType Directory -Force -Path $FontStage | Out-Null
Copy-Item -Path (Join-Path $FontSource 'FiraCodeNerdFont*.ttf') -Destination $FontStage -Force
Start-Process explorer.exe -ArgumentList $FontStage
```

In Explorer, select the copied `.ttf` files, right-click, and choose **Install** (current user). Restart WezTerm after installation. The config selects `FiraCode Nerd Font` and enables the HarfBuzz `calt`, `clig`, and `liga` features for ligatures.

The repo also contains Operator Mono italic fonts. They are optional and commercial: only install them if your license permits use on this Windows machine. To stage them, run:

```powershell
Copy-Item -Path (Join-Path $FontSource 'Operator*.otf') -Destination $FontStage -Force
```

Install those files through Explorer the same way. If Operator Mono is unavailable, WezTerm will use its fallback font for italic text.

## VS Code Settings

The repository also has `settings.json` and `keybindings.json`. The setup script does not overwrite Windows VS Code preferences. Open **Preferences: Open User Settings (JSON)** and **Preferences: Open Keyboard Shortcuts (JSON)** from the Command Palette, then merge in the repo files so existing personal settings are retained. On stable Windows VS Code, the files live under `%APPDATA%\Code\User`. Install the VSCodeVim and Catppuccin extensions for the settings in this repo to take effect.