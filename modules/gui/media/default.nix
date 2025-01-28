{ pkgs, ... }: {
  home.packages = with pkgs; [
    vlc
  ] ++ 
  (lib.optionals stdenv.isLinux [ pwvucontrol ]);
}
