{ pkgs, system, ... }: {
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
    vscode
    docker
    docker-buildx
    docker-compose
    lazydocker
    gnumake
    pscale
    postgresql
  ];
}
