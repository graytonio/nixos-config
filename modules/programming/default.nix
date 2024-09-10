{ pkgs, ... }: {
  home.packages = with pkgs; [
    # Programming languages
    go
    cargo
    rustc
    python3
    pipenv
    gcc

    # DevOps Tools
    kubectl
    k9s
    helm
    kustomize

    docker
    docker-buildx
    docker-compose
  ];
}
