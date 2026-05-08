{pkgs, ...}: {

  home.packages = with pkgs; [
    # Python
    python3
    poetry
    pipenv
    uv
    gcc # Required for cpython modules
  ];
}
