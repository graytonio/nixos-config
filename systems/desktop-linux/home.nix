# A non-NixOS Linux desktop (currently the Arch + KDE gaming PC).
#
# Everything from the shell profile, plus the desktop and gaming apps. The
# Hyprland setup in modules/desktop/hyprland is left out; the host's own
# desktop environment is used instead.
#
# GPU: targets.genericLinux.gpu links Nix's Mesa into /run/opengl-driver so
# Nix-built apps can use the GPU. After the first switch (and whenever
# home-manager warns that drivers need an update) run the printed
# `sudo .../non-nixos-gpu-setup` command once.
#
# Steam stays on the host package manager: the GPU module only provides
# 64-bit drivers, and the Steam client and many Proton games need 32-bit ones.
#
# Lutris also comes from the host package manager (the nixpkgs build breaks
# against gnome-desktop 51). It must run on the host's /usr/bin/python3, not
# the Nix python3 that modules/dev puts first on PATH; the alias below and
# the entries in ~/.local/share/applications/net.lutris.Lutris*.desktop
# both call it that way.
{ lib, ... }: {
  imports = [
    ../shell/home.nix
    ../../modules/desktop
    ../../modules/gaming
    ../../modules/gaming/obs.nix
  ];

  targets.genericLinux.enable = true;

  programs.fish.shellAliases.lutris = "/usr/bin/python3 /usr/bin/lutris";

  programs.fish.shellAliases.nixup = lib.mkForce
    "home-manager switch --flake ~/repos/nixos-config/#desktop-linux --impure";
}
