{pkgs, ...}: {

  home.packages = with pkgs; [
    # Python
    (python311.withPackages (pythonPackages: with pythonPackages; [
      # Global python packages
      dbus-python
      pygobject3
    ]))
    pipenv
    uv
    gcc # Required for cpython modules
  ];
}
