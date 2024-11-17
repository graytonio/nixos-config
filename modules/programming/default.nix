{ pkgs, system, ... }: {
  imports = [
    ./go.nix
    ./python.nix
    ./rust.nix
    ./node.nix

    ./k8s.nix
  ];

  home.packages = with pkgs; [
    docker
    docker-buildx
    docker-compose
  ];
}
