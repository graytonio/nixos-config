# A single switch for "does this machine have a display attached".
#
# Defaults to true so every existing profile (shell-linux, shell-darwin, the
# NixOS and darwin systems) keeps its current package set with no change.
# systems/headless/home.nix sets it false for the Coder workspace container,
# which drops GUI applications that a headless container can never display.
#
# The GUI *modules* (modules/apps) are excluded simply by not importing them.
# This option exists for the GUI packages that live inside otherwise-useful
# modules -- VS Code in modules/dev being the case that prompted it -- where
# not importing is not an option.
{ lib, ... }: {
  options.profiles.gui.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether this machine has a display attached and should install GUI
      applications. Set false for headless containers and servers.
    '';
  };
}
