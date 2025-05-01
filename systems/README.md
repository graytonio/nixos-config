# System Configurations

This directory contains system-specific configurations for different machines. Each subdirectory represents a different physical machine or use case.

## Available System Configurations

### Desktop (`desktop/`)
Configuration for the desktop computer:
- High-performance settings
- Gaming optimizations
- Multiple monitor setup
- Desktop-specific hardware configurations

### Work (`work/`)
Configuration for the work laptop:
- Development environment
- Work-specific applications
- Security settings
- VPN and network configurations

### Laptop (`laptop/`)
Configuration for the personal laptop:
- Power management
- Battery optimizations
- Portable-specific settings
- Personal applications

## Usage

To build and switch to a specific system configuration:

```bash
# For desktop
nixos-rebuild switch --flake .#desktop

# For work laptop
nixos-rebuild switch --flake .#work

# For personal laptop
nixos-rebuild switch --flake .#laptop
```

## Configuration Structure

Each system configuration directory contains:
- `configuration.nix`: Main system configuration
- `hardware-configuration.nix`: Hardware-specific settings
- Additional configuration files as needed

## Customization

Each system configuration can be customized by:
1. Modifying the `configuration.nix` file
2. Adding or removing module imports
3. Adjusting system-specific settings
4. Adding hardware-specific configurations

## Notes

- Hardware configurations are typically generated automatically and should not be modified manually
- System-specific secrets and sensitive information should be managed separately
- Keep track of hardware-specific settings that might need to be adjusted when moving configurations between machines 