# Dotfiles Setup

Run `./setup.sh` from any working directory. The script resolves the repository path from its own location.

```text
./setup.sh [--env desktop|headless|wsl|container|auto] [--yes]
```

Without options, the script detects the environment and asks which profile to use. `--yes` uses the detected profile and keeps an existing Neovim installation. `--env` selects a profile explicitly; `--help` prints all options.

The setup is split into `lib/` modules for shared logging and cleanup, environment selection, system packages, development tools, and dotfile configuration. Required system package and Neovim build failures stop the run with the command and source location. Optional tools are attempted independently; failures are collected, remaining steps continue, and the script exits with status 1 after printing a summary. Rerunning is supported and skips tools that are already installed.

Binary downloads and source builds use unique temporary directories that are removed on exit; optional git checkouts are staged before being moved into place. In particular, lazydocker is installed from a temporary working directory into `~/.local/bin`, so running the script from a read-only checkout does not block its archive download. The shell configuration in this repository adds `~/.local/bin` to `PATH`.

The script targets Ubuntu/Debian and uses `apt`, `sudo`, and a systemd service for Docker when available. It upgrades installed system packages with `apt upgrade`; review `lib/packages.sh` before running if that is not desired. It also changes user configuration and may back up existing dotfiles before linking this checkout.

If `~/.ssh/id_ed25519` is missing, setup creates an Ed25519 keypair there and lets `ssh-keygen` prompt for a passphrase. Existing keys are preserved; if only the private key exists, setup derives the matching public key. SSH keys are machine-specific and are never symlinked from the repository.

For Windows-side WSL and WezTerm setup, including the host font installation and distro profile, see [WINDOWS-WSL.md](../WINDOWS-WSL.md).