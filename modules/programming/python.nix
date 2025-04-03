{pkgs, ...}: {

  home.packages = with pkgs; [
    # Python
    python3
    pipenv
    uv
    gcc # Required for cpython modules
  ];
}
