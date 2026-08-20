{ pkgs, ... }: {
  home.packages = with pkgs; [
    vlc
  ] ++ 
  (lib.optionals stdenv.hostPlatform.isLinux [ pwvucontrol ]);
}
