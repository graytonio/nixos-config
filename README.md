# Nix Configuration

This repository contains my Nix-based system configurations and modules for NixOS, macOS (via nix-darwin), and standalone home-manager. It uses the Nix Flakes system for managing dependencies and configurations.

## Repository Structure

- `modules/`: Reusable home-manager modules organized by tier
  - `base/`: Always-on shell, editor, and CLI tools (every config imports this)
  - `dev/`: Programming languages and dev tooling
  - `apps/`: Cross-platform GUI apps (ghostty, firefox)
  - `desktop/`: Linux-only desktop environment (Hyprland, Linux GUI apps)
  - `gaming/`: NixOS-only gaming tooling

- `systems/`: System-specific configurations
  - `shell/`: Portable home-manager for any non-NixOS Linux or Mac host
  - `nixos/`: Full NixOS host (Hyprland desktop)
  - `darwin/`: Generic nix-darwin baseline (shell + homebrew skeleton)
  - `work/`: Apollo work Mac (extends `darwin/` with work-specific overrides)

## The Four Configurations

### `shell` — portable home-manager (Linux + Mac)

For non-NixOS hosts where you only want user-level configuration.

```bash
nix run home-manager/master -- switch --flake .#shell-linux    # on Linux
nix run home-manager/master -- switch --flake .#shell-darwin   # on Mac
home-manager switch --flake .#shell-linux                      # subsequent rebuilds (Linux)
home-manager switch --flake .#shell-darwin                     # subsequent rebuilds (Mac)
```

### `nixos` — full NixOS host

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### `darwin` — generic Mac with homebrew baseline

```bash
nix run nix-darwin -- switch --flake .#darwin    # bootstrap
darwin-rebuild switch --flake .#darwin           # subsequent rebuilds
```

### `work` — Apollo work Mac (extends `darwin`)

```bash
darwin-rebuild switch --flake .#work
```

## Requirements

- Nix with Flakes support (`experimental-features = nix-command flakes`)
- For `nixos`/`darwin`/`work`: root or sudo for system-wide rebuilds
- For `shell`: no root required

## License

MIT.
