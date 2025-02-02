{ pkgs, system, ... }: {
  imports = [
    ./go.nix
    ./python.nix
    ./rust.nix
    ./node.nix
    ./kotlin.nix

    ./k8s.nix
    ./ai.nix
  ];

  home.packages = with pkgs; [
    vscode
    docker
    docker-buildx
    docker-compose
    lazydocker
    gnumake
    pscale
  ];
}
