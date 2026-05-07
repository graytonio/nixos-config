# Nix Configuration

This repository contains my Nix-based system configurations and modules for NixOS, macOS (via nix-darwin), and standalone home-manager. It uses the Nix Flakes system for managing dependencies and configurations.

## Repository Structure

- `modules/`: Reusable modules that can be imported by different systems
  - `shell/`: Shell-related configurations (zsh, fish, etc.)
  - `programming/`: Development tools and programming environments
  - `gaming/`: Gaming-related configurations and tools
  - `programs/`: General program configurations
  - `gui/`: Graphical user interface configurations
  - `wm/`: Window manager configurations

- `systems/`: System-specific configurations for different machines
  - `desktop/`: NixOS desktop configuration
  - `laptop/`: NixOS personal laptop configuration
  - `work/`: macOS (nix-darwin) work laptop configuration
  - `shell/`: Standalone home-manager configuration for non-NixOS Linux/macOS hosts

## Getting Started

### NixOS

1. Clone this repository
2. Install Nix with Flakes support
3. Build and switch to the desired configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#<system-name>
   ```
   Available systems: `desktop`, `laptop`.

### macOS (nix-darwin)

1. Install Nix using the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer) or the official installer (Flakes support required).
2. Bootstrap nix-darwin:
   ```bash
   nix run nix-darwin -- switch --flake .#work
   ```
3. Subsequent rebuilds:
   ```bash
   darwin-rebuild switch --flake .#work
   ```
   The `work` configuration manages Homebrew taps via `nix-homebrew`, so no separate Homebrew install is required.

### Other Linux / macOS (standalone home-manager)

For non-NixOS hosts where you only want user-level configuration (no system management):

1. Install Nix with Flakes support.
2. Apply the home-manager configuration:
   ```bash
   nix run home-manager/master -- switch --flake .#graytonio
   ```
3. Subsequent rebuilds (once `home-manager` is on PATH):
   ```bash
   home-manager switch --flake .#graytonio
   ```

## Requirements

- Nix with Flakes support (`experimental-features = nix-command flakes`)
- For NixOS / nix-darwin: root or sudo access for system-wide rebuilds
- For standalone home-manager: no root required

## Contributing

Feel free to use this configuration as a reference for your own NixOS setup. If you find any issues or have suggestions, please open an issue or submit a pull request.

## License

This configuration is licensed under the MIT License. See the LICENSE file for details. 