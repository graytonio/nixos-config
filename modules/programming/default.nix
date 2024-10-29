{ pkgs, system, ... }: {
  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  home.packages = with pkgs; [
    # Golang
    go
    gopls
    templ

    # Rust
    cargo
    rustc

    # Python
    (python311.withPackages (pythonPackages: with pythonPackages; [
      dbus-python
      pygobject3
    ]))
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
