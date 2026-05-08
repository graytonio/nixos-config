{ config, pkgs, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    experimental-features = [ "nix-command" "flakes" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gaming-desktop";
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 2022 8080 57621 5353 ];
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.0";
  };
  services.open-webui.enable = true;

  programs.steam.enable = true;
  programs.streamcontroller.enable = true;

  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/30 * * * *	root 	/home/graytonio/Documents/update.sh"
    ];
  };

  programs.gamemode.enable = true;
  services.xserver.videoDrivers = ["amdgpu"];

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.pipewire.extraConfig.pipewire-pulse."20-pulse-properties.conf" = {
    "pulse.properties" = {
      "pulse.min.req" = "256/48000";
      "pulse.min.frag" = "256/48000";
      "pulse.min.quantum" = "256/48000";
    };
  };

  programs.noisetorch = {
    enable = true;
  };

  users.users.graytonio = {
    isNormalUser = true;
    description = "Grayton Ward";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [ 
    pkgs.git 
    pkgs.vim
    pkgs.wget
    pkgs.curl
    pkgs.pwvucontrol
  ];
 
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "graytonio" ];
  virtualisation.waydroid.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ 
    pkgs.xdg-desktop-portal-gtk 
  ];

  fonts.packages = with pkgs;
    #[ (nerdfonts.override { fonts = [ "FiraCode" ]; }) ];
    [ nerd-fonts.fira-code ];

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  system.stateVersion = "24.05"; # Did you read the comment?
}
