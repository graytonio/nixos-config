{pkgs, system, ...}: {
  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  home.packages = with pkgs; [
    openssl
    pkg-config
    cargo-deny
    cargo-edit
    cargo-watch
    rust-analyzer

    libiconv
    cargo
    rustc
  ];
}
