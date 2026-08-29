# A real NixOS machine gets a baseline POSIX userland from the *system*
# profile -- nixos/modules/config/system-path.nix installs gnused, gawk,
# ncurses, diffutils, gnupatch, procps and friends as requiredPackages, so
# nothing in a user profile ever has to think about them.
#
# The Coder workspace container has no NixOS system layer at all: it is the
# nixos/nix base image plus this standalone home-manager profile, and neither
# ships that baseline. Confirmed empirically in a live workspace and again
# against a freshly built ghcr.io/graytonio/nixos-workspace image -- sed, awk,
# clear, tput, infocmp, diff, cmp, patch, ps, top, pgrep, pkill, free, file,
# hostname, zip, bzip2 and xz were all absent from both the base image's root
# profile and the home-manager profile.
#
# This is not cosmetic. Config in this very repo shells out to these:
# modules/base/fish.nix pipes through `sed`, and modules/base/claude-hooks.nix
# uses `awk`. Both fail silently inside the container without this module.
# The same gap is why coder/Dockerfile's login-shell fix had to be written in
# pure POSIX sh -- its first attempt used awk and failed in CI.
#
# ncurses earns its place beyond `clear`: without terminfo, `tput` and
# anything doing terminal capability lookups degrade in the web terminal too.
#
# Linux-only on purpose. On NixOS hosts these merely duplicate what the system
# profile already provides (harmless -- same nixpkgs pin, same derivations),
# but on Darwin they would replace the BSD userland the OS ships with GNU
# equivalents on a machine that has nothing wrong with it.
{ pkgs, lib, ... }: {
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux (with pkgs; [
    gnused
    gawk
    # lowPrio because ncurses and Ghostty (modules/apps, pulled in by
    # shell-linux) both ship share/terminfo/g/ghostty, and home.packages is a
    # single buildEnv -- an unprioritised collision is a hard build failure:
    #
    #   pkgs.buildEnv error: two given paths contain a conflicting subpath:
    #     .../ncurses-6.6/share/terminfo/g/ghostty  and
    #     .../ghostty-1.3.1/share/terminfo/g/ghostty
    #
    # Priority makes Ghostty win that one file, which is the right outcome --
    # its own terminfo is authoritative for it. Verified that everything this
    # package is here for survives the demotion: clear, tput, infocmp, reset
    # and tic all still resolve to ncurses, as does the general terminfo
    # database (xterm-256color, screen, vt100).
    #
    # Note `nix eval` cannot catch this class of error -- collisions only
    # surface when the buildEnv is actually realised, which is why it reached
    # CI. Build home.path, don't just evaluate it, when touching this list.
    (lib.lowPrio ncurses)
    diffutils
    gnupatch
    procps
    file
    hostname
    zip
    bzip2
    xz
  ]);
}
