# Headless profile: the Coder workspace container and anything else that is a
# shell with no display attached.
#
# Differs from systems/shell/home.nix in two ways that matter:
#
# 1. It does not import ../../modules/apps (Ghostty, Firefox) and sets
#    profiles.gui.enable = false, which also drops VS Code from modules/dev.
#    Those are GUI applications that a container can never display, and they
#    are not free: measured against the flake's own nixpkgs pin, ghostty is a
#    1.00 GB closure, firefox 1.52 GB and vscode 2.34 GB, out of an 8.94 GB
#    shell-linux profile. They also caused a real build failure -- ncurses and
#    Ghostty both ship share/terminfo/g/ghostty, which is a hard buildEnv
#    collision (see modules/base/posix-tools.nix). Dropping the GUI removes
#    that entire class of conflict from the container.
#
# 2. It is pure. systems/shell/home.nix reads $USER/$HOME via builtins.getEnv
#    and therefore requires --impure; the container always runs as the same
#    user at the same path, so hardcoding them lets coder/Dockerfile activate
#    this without --impure and makes the build reproducible from the flake
#    alone.
{ ... }: {
  home.username = "coder";
  home.homeDirectory = "/home/coder";

  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../modules/base
    ../../modules/dev
  ];

  profiles.gui.enable = false;

  # No `nixup` alias here on purpose. The container's profile is baked into
  # the image by coder/Dockerfile and rebuilt by CI, not switched in place --
  # an in-workspace `home-manager switch` would write to the PVC and silently
  # diverge from the image on the next workspace start.

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
