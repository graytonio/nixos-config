{ pkgs, system, ... }: {
  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  home.packages = with pkgs; [
    # Programming languages
    go
    gopls
    templ

    cargo
    rustc
    python3
    pipenv
    gcc
    gnumake

    # DevOps Tools
    kubectl
    k9s
    helm
    kustomize
    awscli2

    docker
    docker-buildx
    docker-compose
  ];

  programs.fish = {
	shellAliases = {
		k = "kubectl";
	};
  };
}
