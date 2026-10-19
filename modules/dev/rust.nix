{pkgs, inputs, ...}:
let
  fenix = inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system};

  # Stable toolchain plus std for extra cross-compilation targets.
  # thumbv6m-none-eabi: Cortex-M0+ (RP2040, e.g. Badger 2040).
  rustToolchain = fenix.combine [
    fenix.stable.cargo
    fenix.stable.rustc
    fenix.stable.rust-src
    fenix.targets.thumbv6m-none-eabi.stable.rust-std
  ];
in
{
  home.sessionVariables = {
    RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  home.packages = with pkgs; [
    openssl
    pkg-config
    cargo-deny
    cargo-edit
    cargo-watch
    rust-analyzer
    lld
    elf2uf2-rs

    libiconv
    rustToolchain
  ];
}
