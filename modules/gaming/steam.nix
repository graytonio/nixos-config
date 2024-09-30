{pkgs, inputs, ... }:
let
  unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
in
{
  home.packages = [
    pkgs.mangohud
    pkgs.protonup
    unstable.gamescope
  ];
}
