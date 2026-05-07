# Flake restructure: four-configuration layout

## Goal

Restructure the flake so that the laptop is no longer a NixOS configuration. Instead, deliver four well-defined outputs:

1. **`shell`** — portable home-manager for any non-NixOS Linux or Mac host. Includes shell + dev tooling + a small set of cross-platform GUI apps (ghostty, firefox).
2. **`nixos`** — full NixOS host (replaces both current `laptop` and `desktop` NixOS configs). Shell + dev + portable GUI apps + a Linux-only desktop layer (Hyprland WM, additional GUI apps).
3. **`darwin`** — generic nix-darwin baseline: shell + dev + portable GUI apps + nix-homebrew skeleton (taps registered, no apps).
4. **`work`** — extends `darwin` with Apollo-specific overrides at the home-manager layer (git email, mise, slack-cli helpers, work tmux bindings, work-only homebrew taps).

The current `nixosConfigurations.laptop` is removed entirely. The current `homeConfigurations.graytonio` is replaced by the richer portable `shell` config.

## Module layout

The current `modules/` directory is reorganized into tiers reflecting how each configuration uses them.

```
modules/
  base/                         # always-on (every config imports)
    default.nix                 # imports fish, starship, tmux, claude-hooks, nvim, yazi; declares git, base CLI tools
    fish.nix
    starship.nix
    tmux.nix
    claude-hooks.nix
    nvim/                       # moved from modules/programs/nvim/
    yazi/                       # moved from modules/programs/yazi/

  dev/                          # programming languages & dev tooling (every config imports)
    default.nix                 # imports go, node, python, rust, kotlin, k8s + base dev packages
    go.nix node.nix python.nix rust.nix kotlin.nix k8s.nix
    apollo.nix                  # NOT imported by default.nix; opt-in (Linux-only — hardcodes /etc/profiles paths)
    spacetimedb.nix             # NOT imported by default.nix; opt-in

  apps/                         # portable GUI apps (cross-platform, HM-managed)
    default.nix                 # imports ghostty, firefox
    ghostty.nix
    firefox.nix

  desktop/                      # NixOS-only: Hyprland WM + Linux-only GUI apps
    default.nix
    hyprland/                   # moved from modules/wm/hyprland/
    alacritty.nix kitty.nix discord.nix spotify.nix obsidian.nix media.nix

  gaming/                       # unchanged, NixOS-only, optionally imported by `nixos` config
```

Removed directories: `modules/shell/`, `modules/programs/`, `modules/programming/`, `modules/gui/`, `modules/wm/`. Their contents move under the new tiers.

### Module-tier rules

- `base` and `dev/default.nix` are HM-only and platform-independent. Anything Linux-only or NixOS-only stays out of these tiers.
- `dev/apollo.nix` and `dev/spacetimedb.nix` are opt-in extras with platform constraints; configs that need them import the file directly. They are NOT imported by `dev/default.nix`.
- `apps` is HM-only, cross-platform. Any GUI app added here must work on both `x86_64-linux` and `aarch64-darwin`.
- `desktop` may use NixOS-only options (`programs.hyprland`, etc.) and Linux-only packages. Only the `nixos` config imports it.
- `gaming` follows the same NixOS-only rule as `desktop`.

## System layout

```
systems/
  shell/
    home.nix                    # imports base + dev + apps; sets username/homeDir, nixup alias
  nixos/
    configuration.nix           # NixOS system layer (Hyprland, GDM, GNOME, pipewire, NetworkManager, fonts, fish, allowUnfree)
    hardware-configuration.nix  # carried forward from current systems/desktop/
    home.nix                    # imports base + dev + apps + desktop
  darwin/
    configuration.nix           # nix-darwin system layer (fonts, fish, stateVersion); used by both darwin & work
    home.nix                    # imports base + dev + apps
  work/
    home.nix                    # imports ../darwin/home.nix; overrides git email; adds mise/slack-cli helpers/work tmux bindings
    # no configuration.nix — work reuses ../darwin/configuration.nix via the flake
```

Removed directories: `systems/laptop/` (entirely), `systems/desktop/` (renamed to `systems/nixos/`). The current `systems/work/configuration.nix` is removed in favor of `systems/darwin/configuration.nix`.

## Flake outputs

```nix
outputs = { nixpkgs, nix-darwin, home-manager, hyprland, hyprpanel, nur,
            nix-homebrew, homebrew-core, homebrew-cask, deskflow, brief, ... }@inputs:
let
  mkHome = system: module: home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.${system};
    extraSpecialArgs = { inherit inputs; };
    modules = [ module ];
  };
in {
  formatter.x86_64-linux   = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
  formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt;

  homeConfigurations."shell-linux"  = mkHome "x86_64-linux"   ./systems/shell/home.nix;
  homeConfigurations."shell-darwin" = mkHome "aarch64-darwin" ./systems/shell/home.nix;

  nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    system = "x86_64-linux";
    modules = [
      ./systems/nixos/configuration.nix
      nur.modules.nixos.default
      hyprland.nixosModules.default
      { nixpkgs.overlays = [ hyprpanel.overlay ]; }
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.graytonio = import ./systems/nixos/home.nix;
      }
    ];
  };

  darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
      ./systems/darwin/configuration.nix
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.graytonw = import ./systems/darwin/home.nix;
      }
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          user = "graytonw";
          mutableTaps = false;
          taps = {
            "homebrew/homebrew-core" = homebrew-core;
            "homebrew/homebrew-cask" = homebrew-cask;
          };
        };
      }
      ({ config, ... }: { homebrew.taps = builtins.attrNames config.nix-homebrew.taps; })
    ];
  };

  darwinConfigurations.work = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
      ./systems/darwin/configuration.nix
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.graytonw = import ./systems/work/home.nix;
      }
      nix-homebrew.darwinModules.nix-homebrew
      {
        nix-homebrew = {
          enable = true;
          enableRosetta = true;
          user = "graytonw";
          mutableTaps = false;
          taps = {
            "homebrew/homebrew-core"   = homebrew-core;
            "homebrew/homebrew-cask"   = homebrew-cask;
            "deskflow/homebrew-tap"    = deskflow;
            "graytonio/homebrew-brief" = brief;
          };
        };
      }
      ({ config, ... }: { homebrew.taps = builtins.attrNames config.nix-homebrew.taps; })
    ];
  };
};
```

### Notes on the shape

- Standalone home-manager isn't keyed by system, so the portable `shell` config is exposed twice: `shell-linux` (`x86_64-linux`) and `shell-darwin` (`aarch64-darwin`). The user invokes whichever matches the host: `home-manager switch --flake .#shell-linux` or `.#shell-darwin`. The same `systems/shell/home.nix` powers both.
- `work` reuses `systems/darwin/configuration.nix` directly. There is no `systems/work/configuration.nix`. If a future need arises for work-specific system config, add it then.
- Work's homebrew taps superset darwin's: it adds `deskflow/homebrew-tap` and `graytonio/homebrew-brief`. If those should be generic in the future, they can be moved to the darwin baseline.

## Per-config home.nix shapes

### `systems/shell/home.nix`

```nix
{ pkgs, lib, ... }: {
  home.username = if pkgs.stdenv.isDarwin then "graytonw" else "graytonio";
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/graytonw" else "/home/graytonio";

  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/apps
  ];

  programs.fish.shellAliases.nixup =
    if pkgs.stdenv.isDarwin
    then "home-manager switch --flake ~/repos/nixos-config/#shell-darwin"
    else "home-manager switch --flake ~/repos/nixos-config/#shell-linux";

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
```

A single `systems/shell/home.nix` powers both `shell-linux` and `shell-darwin`. Username and home-directory default to the historical values per platform (`graytonio` on Linux, `graytonw` on Mac, mirroring the `darwin`/`work` configs). If the user later runs the portable shell on a host with a different username, override at the import site or fork the file.

### `systems/nixos/home.nix`

```nix
{ pkgs, ... }: {
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/apps
    ../../modules/desktop
    ../../modules/gaming             # carry forward from current desktop home
    ../../modules/gaming/obs.nix     # opt-in extra, currently imported by desktop
  ];

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
  };

  hyprlandMonitors = [
    "DP-1,preferred,0x0,1"
    "DP-2,preferred,-1440x-480,1,transform,1"
  ];

  home.packages = with pkgs; [ rocmPackages.rocm-runtime ];

  programs.fish.shellAliases.nixup =
    "sudo nixos-rebuild switch --flake ~/repos/nixos-config/#nixos";

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
```

These host-specific bits (cursor sizes, monitor layout, rocm runtime) are carried forward verbatim from the current `systems/desktop/home.nix`. They sit at the top level of `nixos/home.nix` rather than inside a module because they're tied to this specific machine.

### `systems/darwin/home.nix`

```nix
{ pkgs, ... }: {
  home.username = "graytonw";
  home.homeDirectory = "/Users/graytonw";

  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/apps
  ];

  programs.fish.shellAliases.nixup =
    "darwin-rebuild switch --flake ~/repos/nixos-config/#darwin";

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
```

### `systems/work/home.nix`

```nix
{ config, pkgs, ... }: {
  imports = [ ../darwin/home.nix ];

  home.packages = [ pkgs.mise ];

  programs.git.settings.user.email = "grayton.ward@apollographql.com";

  programs.fish = {
    shellAliases.nixup = pkgs.lib.mkForce
      "darwin-rebuild switch --flake ~/repos/nixos-config/#work";

    functions = {
      slack-send.body = "...";       # current content preserved
      slack-send.argumentNames = "to";
      slack-tui.body = "...";        # current content preserved
    };

    interactiveShellInit = "...";    # current mise + brew google-cloud-sdk content preserved
  };

  programs.tmux.extraConfig = ''
    bind C-q run-shell "fish -c 'tmux-session /Users/graytonw/repos/monorepo'"
    bind C-w run-shell "fish -c 'tmux-session /Users/graytonw/repos/apollo-argo'"
    bind C-e run-shell "fish -c 'tmux-session /Users/graytonw/repos/scratch'"
  '';
}
```

The work home.nix only adds the bits that are work-specific. Everything generic (modules, basic fish setup, etc.) is inherited from `darwin/home.nix`.

## Migration sequence

The work happens in three phases. Each phase ends with a fully working flake — verify before moving to the next.

### Phase 1: Module reorganization

Move existing modules into the new tiered directories, with no behavioral change.

1. Create `modules/base/`, `modules/dev/`, `modules/apps/`, `modules/desktop/`.
2. Move:
   - `modules/shell/*` → `modules/base/` (fish, starship, tmux, claude-hooks at root)
   - `modules/programs/nvim` → `modules/base/nvim`
   - `modules/programs/yazi` → `modules/base/yazi`
   - `modules/programming/*` → `modules/dev/*`
   - `modules/gui/{alacritty,kitty,discord,spotify,obsidian,media}` → `modules/desktop/`
   - `modules/wm/hyprland` → `modules/desktop/hyprland`
3. Create `modules/apps/{ghostty.nix,firefox.nix,default.nix}` with new HM-managed configurations for those two apps.
4. Update `modules/base/default.nix` to import fish, starship, tmux, claude-hooks, nvim, yazi (the merged contents of the old `modules/shell/default.nix` and `modules/programs/*`).
5. Update `modules/desktop/default.nix` to import the moved Linux-only GUI app modules and the hyprland subdirectory.
6. Update import paths in **all current** `systems/*/home.nix` files (laptop, desktop, work, shell) to point at the new module locations. This keeps the four existing flake outputs (`laptop`, `desktop`, `work`, `graytonio`) building.
7. Verify: `nix flake check`, build each existing config (`nixos-rebuild build --flake .#laptop`, `.#desktop`, `darwin-rebuild build --flake .#work`, `home-manager build --flake .#graytonio`).

Commit at the end of phase 1.

### Phase 2: Add new outputs alongside old

1. Create `systems/nixos/` (copy contents from `systems/desktop/`), `systems/darwin/` (new), and rewrite `systems/work/home.nix` to import `../darwin/home.nix`. For now, the old `systems/desktop/`, `systems/laptop/`, and `systems/work/configuration.nix` still exist on disk so the old outputs continue to build.
2. Update `systems/shell/home.nix` to the new richer version (base + dev + apps + cross-platform username/homeDir logic).
3. Add new flake outputs alongside the existing ones: `homeConfigurations.shell-linux`, `homeConfigurations.shell-darwin`, `nixosConfigurations.nixos`, `darwinConfigurations.darwin`. Rewrite `darwinConfigurations.work` in place to use `systems/darwin/configuration.nix` and `systems/work/home.nix`.
4. Verify: build the new outputs.
   - `home-manager build --flake .#shell-linux` (on Linux)
   - `home-manager build --flake .#shell-darwin` (on Mac)
   - `nixos-rebuild build --flake .#nixos`
   - `darwin-rebuild build --flake .#darwin`
   - `darwin-rebuild build --flake .#work`
5. Verify the still-existing old outputs (`laptop`, `desktop`, `graytonio`) continue to build.

Commit at the end of phase 2.

### Phase 3: Remove old

1. Delete `systems/laptop/`.
2. Delete `systems/desktop/`.
3. Delete the old `homeConfigurations.graytonio`, `nixosConfigurations.laptop`, and `nixosConfigurations.desktop` outputs from `flake.nix`. (`nixosConfigurations.nixos` replaces both.)
4. Update `README.md` to describe the four new configurations and how to invoke each.
5. Verify: `nix flake check` shows only the four intended outputs.

Commit at the end of phase 3.

## Risks & mitigations

- **Module-import path breakage:** moving directories breaks every relative `imports = [ ../../modules/... ]`. Mitigated by phase 1's "update all import paths in one pass and verify all four existing builds before committing."
- **Hyprland HM module references:** the current `modules/wm/hyprland/` may reference `inputs.hyprland.packages` or use NixOS-only options at the HM layer. Audit during phase 1 — if anything is NixOS-only, it must stay in the `desktop` tier (only `nixos` imports it).
- **Ghostty/Firefox cross-platform:** new modules under `modules/apps/` must work on both Linux and Darwin. Use `programs.ghostty` and `programs.firefox` from home-manager where supported; if either has Darwin caveats, document them in the module rather than splitting the module. If a clean cross-platform setup turns out to be infeasible for one of them, fall back to per-platform `lib.mkIf pkgs.stdenv.isDarwin` branches inside the module.
- **Standalone HM cross-system invocation:** `nix flake check` on a Linux box can't evaluate `shell-darwin` and vice versa. Acceptable for personal config; verify each output on its native platform.
- **Work fish overrides:** the work `home.nix` re-imports the darwin one, which already sets `programs.fish.shellAliases.nixup`. Use `lib.mkForce` on the work side for the alias override (shown in the sketch above).
- **Apollo module hardcodes Linux paths:** `modules/dev/apollo.nix` references `/etc/profiles/per-user/graytonw/bin/mise`. It's not in `dev/default.nix`, so importing `dev` won't pull it in. The `work` config currently inlines this same fish setup (in `interactiveShellInit`); this refactor preserves the inline content rather than switching `work` to import `dev/apollo.nix`. Consolidating those two copies is out of scope.

## Out of scope

- Splitting the (currently empty) homebrew brew/cask lists into generic vs work — the existing config doesn't define any. Add when an actual list is introduced.
- Deciding whether `deskflow/homebrew-tap` and `graytonio/homebrew-brief` are generic or work-specific. They stay work-specific in this design; revisit later.
- Reorganizing `modules/gaming/` — left as-is.
- Any new functionality (new GUI apps, new dev tooling). This refactor is structural only.
- Distro-specific bootstrap notes for the host of `shell-linux`. Spec assumes Nix is already installed with flakes enabled.
