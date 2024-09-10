{config, pkgs, ...}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    globals.mapleader = " ";

    keymaps = [
      {
        mode = "n";
        key = "<leader>pv";
        action = "<cmd>Ex<CR>";
      }
    ];
  };
}}
