# NixOS Modules

This directory contains reusable NixOS modules that can be imported by different system configurations. Each module focuses on a specific aspect of the system configuration.

## Available Modules

### Shell (`shell/`)
Contains configurations for various shells and shell-related tools:
- Shell configurations (zsh, fish, etc.)
- Shell plugins and utilities
- Terminal emulator settings

### Programming (`programming/`)
Development tools and programming environments:
- Language-specific toolchains
- Development tools and IDEs
- Version control systems
- Build tools and package managers

### Gaming (`gaming/`)
Gaming-related configurations:
- Steam and other gaming platforms
- Gaming peripherals
- Performance optimizations
- Game-specific configurations

### Programs (`programs/`)
General program configurations:
- System utilities
- Productivity tools
- Media applications
- Network tools

### GUI (`gui/`)
Graphical user interface configurations:
- Display server settings
- Desktop environments
- Input device configurations
- Display settings

### Window Manager (`wm/`)
Window manager configurations:
- Window manager settings
- Status bars and panels
- Window management utilities
- Theme configurations

## Usage

To use these modules in your system configuration:

1. Import the desired module in your system's configuration:
   ```nix
   imports = [
     ./modules/shell
     ./modules/programming
     # ... other modules
   ];
   ```

2. Configure the module options as needed in your system configuration.

## Customization

Each module can be customized through NixOS options. Refer to the specific module's documentation for available options and configuration examples. 