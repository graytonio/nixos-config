{ pkgs, lib, config, system, ... }: {
  imports = [
    ./go.nix
    ./python.nix
    ./rust.nix
    ./node.nix
    ./kotlin.nix

    ./k8s.nix
  ];

  home.packages = with pkgs; [
    just
    docker
    docker-buildx
    docker-compose
    lazydocker
    gnumake
    pscale
    postgresql
  ] ++ lib.optionals config.profiles.gui.enable [
    # A GUI editor in an otherwise headless-capable module. Gated rather than
    # moved to modules/apps because it belongs with the dev toolchain on a
    # desktop -- it is only unwanted where there is no display, and it is the
    # single largest package in this profile (2.34 GB closure).
    vscode
  ];
}
