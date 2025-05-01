# NixOS Configuration

This repository contains my NixOS system configurations and modules. It uses the Nix Flakes system for managing dependencies and configurations.

## Repository Structure

- `modules/`: Reusable NixOS modules that can be imported by different systems
  - `shell/`: Shell-related configurations (zsh, fish, etc.)
  - `programming/`: Development tools and programming environments
  - `gaming/`: Gaming-related configurations and tools
  - `programs/`: General program configurations
  - `gui/`: Graphical user interface configurations
  - `wm/`: Window manager configurations

- `systems/`: System-specific configurations for different machines
  - `desktop/`: Desktop computer configuration
  - `work/`: Work laptop configuration
  - `laptop/`: Personal laptop configuration

## Getting Started

1. Clone this repository
2. Install Nix with Flakes support
3. Build and switch to the desired configuration:
   ```bash
   nixos-rebuild switch --flake .#<system-name>
   ```

## Requirements

- NixOS with Flakes support
- Root access for system-wide configurations

## Contributing

Feel free to use this configuration as a reference for your own NixOS setup. If you find any issues or have suggestions, please open an issue or submit a pull request.

## License

This configuration is licensed under the MIT License. See the LICENSE file for details. 