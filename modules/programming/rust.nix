{pkgs, system, ...}: {
  home.sessionVariables = {
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
  };

  home.packages = with pkgs; [
    cargo
    rustc
  ];
}
