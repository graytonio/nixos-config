{pkgs, ...}: {

  home.packages = with pkgs; [
    # Python
    (python311.withPackages (pythonPackages: with pythonPackages; [
      # Global python packages
      dbus-python
      pygobject3
      pyautogui
    ]))
    pipenv
    gcc # Required for cpython modules
  ];
}
