# Flake Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the flake from `{laptop, desktop, work, graytonio}` outputs into four well-defined outputs (`shell-linux`/`shell-darwin`, `nixos`, `darwin`, `work`) with reorganized `base/dev/apps/desktop` module tiers. The laptop is no longer a NixOS host — it becomes the portable home-manager `shell` config.

**Architecture:** Three phases. (1) Atomic module reorganization that keeps all four current outputs building under new module paths. (2) Add the new outputs alongside the old. (3) Remove the old outputs and orphaned files. Each phase ends with a fully-evaluating flake.

**Tech Stack:** Nix flakes, nixpkgs unstable, home-manager, nix-darwin, nix-homebrew. Working directory: `/Users/graytonw/repos/nixos-config`.

**Spec reference:** `docs/superpowers/specs/2026-05-07-flake-restructure-design.md`

**Verification environment note:** The implementer is on aarch64-darwin (Mac). NixOS configs cannot be fully built locally — verify them with `nix eval` on the derivation path (cross-platform) and full `nixos-rebuild build` only on the actual NixOS host. Darwin and standalone-HM configs can be fully built on the Mac.

---

## File Structure

After this plan completes:

```
flake.nix                                       # rewritten outputs
modules/
  base/                                         # new (was modules/shell + programs/nvim + programs/yazi)
    default.nix
    fish.nix starship.nix tmux.nix claude-hooks.nix
    nvim/{default.nix,plugins/...}
    yazi/default.nix
  dev/                                          # new (was modules/programming)
    default.nix
    go.nix node.nix python.nix rust.nix kotlin.nix k8s.nix
    apollo.nix spacetimedb.nix                  # not in default.nix; opt-in
  apps/                                         # new
    default.nix
    ghostty.nix firefox.nix
  desktop/                                      # new (was modules/gui + modules/wm/hyprland)
    default.nix
    alacritty.nix kitty.nix discord.nix spotify.nix obsidian.nix media.nix
    hyprland/{default.nix,hyprland.nix,hyprpanel.nix,mako.nix,rofi.nix,waybar.nix,catppuccin-mocha.rasi}
  gaming/                                       # unchanged
    default.nix steam.nix obs.nix
systems/
  shell/home.nix                                # rewritten: cross-platform username + base+dev+apps
  nixos/                                        # new (was systems/desktop)
    configuration.nix hardware-configuration.nix home.nix
  darwin/                                       # new
    configuration.nix home.nix
  work/home.nix                                 # rewritten: imports ../darwin/home.nix
README.md                                       # rewritten
```

Removed: `modules/shell/`, `modules/programs/`, `modules/programming/`, `modules/gui/`, `modules/wm/`, `systems/laptop/`, `systems/desktop/`, `systems/work/configuration.nix`.

---

## Task 1: Add `modules/apps` with ghostty and firefox

**Rationale:** Purely additive — establishes the new tier without breaking anything. Easy first commit, gives us module files to reference in later tasks.

**Files:**
- Create: `modules/apps/default.nix`
- Create: `modules/apps/ghostty.nix`
- Create: `modules/apps/firefox.nix`

- [ ] **Step 1: Create `modules/apps/ghostty.nix`**

```nix
{ pkgs, lib, ... }: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
  };
}
```

If `nix eval` later complains that `programs.ghostty` doesn't exist (older home-manager release), replace with the package-only fallback:

```nix
{ pkgs, ... }: {
  home.packages = [ pkgs.ghostty ];
}
```

- [ ] **Step 2: Create `modules/apps/firefox.nix`**

```nix
{ pkgs, lib, ... }: {
  programs.firefox.enable = true;
}
```

This works on both Linux and macOS via Nix. Mac users may eventually prefer a homebrew cask, but Nix-installed Firefox is functional.

- [ ] **Step 3: Create `modules/apps/default.nix`**

```nix
{ ... }: {
  imports = [
    ./ghostty.nix
    ./firefox.nix
  ];
}
```

- [ ] **Step 4: Verify the new modules evaluate in isolation**

Nothing imports them yet, so just confirm the flake still evaluates as a whole.

Run: `nix flake check --no-build`
Expected: no errors. (Warnings about deprecated outputs are fine.)

- [ ] **Step 5: Commit**

```bash
git add modules/apps
git commit -m "feat: add modules/apps with ghostty and firefox

Cross-platform GUI app modules for the new portable shell config and
darwin baseline. Not yet imported by any output."
```

---

## Task 2: Reorganize `modules/` into base/dev/desktop tiers (atomic)

**Rationale:** Atomic move + import-update so all four current outputs (`laptop`, `desktop`, `work`, `graytonio`) keep building under new module paths. After this commit, no more references to `modules/{shell,programs,programming,gui,wm}`.

**Files:**
- Move: `modules/shell/*.nix` → `modules/base/`
- Move: `modules/programs/nvim/` → `modules/base/nvim/`
- Move: `modules/programs/yazi/` → `modules/base/yazi/`
- Move: `modules/programming/` → `modules/dev/`
- Move: `modules/gui/alacritty/default.nix` → `modules/desktop/alacritty.nix`
- Move: `modules/gui/kitty/default.nix` → `modules/desktop/kitty.nix`
- Move: `modules/gui/discord/default.nix` → `modules/desktop/discord.nix`
- Move: `modules/gui/spotify/default.nix` → `modules/desktop/spotify.nix`
- Move: `modules/gui/obsidian/default.nix` → `modules/desktop/obsidian.nix`
- Move: `modules/gui/media/default.nix` → `modules/desktop/media.nix`
- Move: `modules/wm/hyprland/` → `modules/desktop/hyprland/`
- Modify: `modules/base/default.nix` (replace; merges old `modules/shell/default.nix` content + nvim/yazi imports)
- Create: `modules/desktop/default.nix`
- Modify: `systems/laptop/home.nix` (import paths)
- Modify: `systems/desktop/home.nix` (import paths)
- Modify: `systems/work/home.nix` (import paths)
- Modify: `systems/shell/home.nix` (import paths)

- [ ] **Step 1: Move shell files to base**

```bash
git mv modules/shell modules/base
```

- [ ] **Step 2: Move nvim and yazi into base**

```bash
git mv modules/programs/nvim modules/base/nvim
git mv modules/programs/yazi modules/base/yazi
rmdir modules/programs
```

- [ ] **Step 3: Move programming to dev**

```bash
git mv modules/programming modules/dev
```

- [ ] **Step 4: Move hyprland to desktop**

```bash
mkdir modules/desktop
git mv modules/wm/hyprland modules/desktop/hyprland
rmdir modules/wm
```

- [ ] **Step 5: Move gui apps to desktop (flatten)**

```bash
git mv modules/gui/alacritty/default.nix modules/desktop/alacritty.nix
git mv modules/gui/kitty/default.nix     modules/desktop/kitty.nix
git mv modules/gui/discord/default.nix   modules/desktop/discord.nix
git mv modules/gui/spotify/default.nix   modules/desktop/spotify.nix
git mv modules/gui/obsidian/default.nix  modules/desktop/obsidian.nix
git mv modules/gui/media/default.nix     modules/desktop/media.nix
rmdir modules/gui/alacritty modules/gui/kitty modules/gui/discord modules/gui/spotify modules/gui/obsidian modules/gui/media
rmdir modules/gui
```

- [ ] **Step 6: Rewrite `modules/base/default.nix`**

Replace the file with the merged content (current `modules/shell/default.nix` unchanged content, plus nvim and yazi imports):

```nix
{ config, pkgs, lib, ... }: {
  imports = [
    ./fish.nix
    ./starship.nix
    ./tmux.nix
    ./claude-hooks.nix
    ./nvim
    ./yazi
  ];

  home.packages = with pkgs; [
    which
    jq
    terminal-notifier
    yq-go
    direnv
    dust
    rsync
    rclone
    btop
    unzip
    yt-dlp
    just
    (writeShellScriptBin "tmux-claude-status" ''
      FILE="$HOME/.local/share/tmux-claude-waiting"
      if [ -f "$FILE" ] && grep -q '[^[:space:]]' "$FILE" 2>/dev/null; then
        echo "● claude"
      fi
    '')
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Grayton Ward";
      user.email = lib.mkDefault "graytonio.ward@gmail.com";
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };

  home.sessionVariables = {
    BROWSER = "firefox";
    TERMINAL = "alacritty";
  };
}
```

- [ ] **Step 7: Create `modules/desktop/default.nix`**

```nix
{ ... }: {
  imports = [
    ./alacritty.nix
    ./kitty.nix
    ./discord.nix
    ./spotify.nix
    ./obsidian.nix
    ./media.nix
    ./hyprland
  ];
}
```

Note: `hyprland` is a directory with its own `default.nix` — Nix resolves the import to that file.

- [ ] **Step 8: Update `systems/laptop/home.nix` import paths**

The current imports list reaches into the old paths. Replace with the new tiered imports. The laptop config is going to be deleted in Phase 3, but for this phase it must keep building.

```nix
{ config, pkgs, ... }: {
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/desktop
  ];

  hyprlandMonitors = [
    "eDP-1,preferred,0x0,2"
  ];

  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "48";
    HYPRCURSOR_SIZE = "48";
  };

  programs.fish = {
    shellAliases = {
      nixup = "sudo nixos-rebuild switch --flake ~/nixos-config/#laptop";
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
```

- [ ] **Step 9: Update `systems/desktop/home.nix` import paths**

```nix
{ pkgs, ... }: {
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/dev/spacetimedb.nix
    ../../modules/desktop
    ../../modules/gaming
    ../../modules/gaming/obs.nix
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

  programs.fish = {
    shellAliases = {
      nixup = "sudo nixos-rebuild switch --flake ~/nixos-config/#desktop";
    };
  };

  home.packages = with pkgs; [
    rocmPackages.rocm-runtime
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
```

- [ ] **Step 10: Update `systems/work/home.nix` import paths**

Only the `imports = [ ../../modules/shell ../../modules/programs/nvim ];` line changes. Replace it with `../../modules/base` (which already includes nvim). Everything else in `systems/work/home.nix` stays exactly as it is for now — it gets rewritten in Task 5.

```nix
# At top of file, replace:
#   imports = [
#     ../../modules/shell
#     ../../modules/programs/nvim
#   ];
# with:
  imports = [
    ../../modules/base
  ];
```

- [ ] **Step 11: Update `systems/shell/home.nix` import paths**

```nix
{ pkgs, ... }: {
  home.username = "graytonio";
  home.homeDirectory = "/home/graytonio";

  imports = [
    ../../modules/base
  ];

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
```

- [ ] **Step 12: Verify all four current outputs evaluate**

Run each in turn from `/Users/graytonw/repos/nixos-config`:

```bash
nix eval --raw ".#nixosConfigurations.laptop.config.system.build.toplevel.drvPath"
nix eval --raw ".#nixosConfigurations.desktop.config.system.build.toplevel.drvPath"
nix eval --raw ".#darwinConfigurations.work.config.system.build.toplevel.drvPath"
nix build --no-link ".#homeConfigurations.graytonio.activationPackage" --print-out-paths
```

Expected: each command prints a `/nix/store/...` path. No evaluation errors.

If any fails, the most likely causes are: (a) a missed import path inside one of the moved modules; (b) a relative `imports = [ ./... ]` that became invalid because of directory restructuring. Fix the offending file and re-run.

- [ ] **Step 13: Build the work output (full build, since we're on Mac)**

```bash
darwin-rebuild build --flake ".#work"
```

Expected: builds cleanly, prints a `result/` symlink path.

- [ ] **Step 14: Commit**

```bash
git add modules systems
git commit -m "refactor: reorganize modules into base/dev/desktop tiers

Move modules/shell + modules/programs/{nvim,yazi} into modules/base.
Move modules/programming into modules/dev. Move modules/gui and
modules/wm/hyprland into modules/desktop. All four current outputs
(laptop, desktop, work, graytonio) updated to use new paths.

No behavioral change."
```

---

## Task 3: Add `nixosConfigurations.nixos` (replaces desktop+laptop)

**Rationale:** Stand up the consolidated NixOS config alongside existing `laptop` and `desktop` so we can verify it builds before removing the old outputs.

**Files:**
- Create: `systems/nixos/configuration.nix` (copied from `systems/desktop/configuration.nix`)
- Create: `systems/nixos/hardware-configuration.nix` (copied from `systems/desktop/hardware-configuration.nix`)
- Create: `systems/nixos/home.nix` (copied from `systems/desktop/home.nix` + apps imports + alias rename)
- Modify: `flake.nix` (add `nixosConfigurations.nixos`)

- [ ] **Step 1: Copy desktop system files to nixos**

```bash
cp -r systems/desktop systems/nixos
```

(Use `cp` not `git mv` here — the desktop directory must continue to exist for now so `nixosConfigurations.desktop` keeps building.)

- [ ] **Step 2: Add `apps` import to `systems/nixos/home.nix`**

Edit the `imports` list in `systems/nixos/home.nix`:

```nix
  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/dev/spacetimedb.nix
    ../../modules/apps
    ../../modules/desktop
    ../../modules/gaming
    ../../modules/gaming/obs.nix
  ];
```

- [ ] **Step 3: Update `nixup` alias in `systems/nixos/home.nix`**

```nix
  programs.fish = {
    shellAliases = {
      nixup = "sudo nixos-rebuild switch --flake ~/nixos-config/#nixos";
    };
  };
```

- [ ] **Step 4: Add `nixosConfigurations.nixos` to `flake.nix`**

In the `outputs` block, immediately after `nixosConfigurations.desktop`, add:

```nix
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [
        ./systems/nixos/configuration.nix
        nur.modules.nixos.default
        hyprland.nixosModules.default
        {nixpkgs.overlays = [hyprpanel.overlay];}
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.graytonio = import ./systems/nixos/home.nix;
        }
      ];
    };
```

- [ ] **Step 5: Verify it evaluates**

```bash
nix eval --raw ".#nixosConfigurations.nixos.config.system.build.toplevel.drvPath"
```

Expected: prints a `/nix/store/...` path.

Also verify the existing `desktop` and `laptop` configs still evaluate:

```bash
nix eval --raw ".#nixosConfigurations.desktop.config.system.build.toplevel.drvPath"
nix eval --raw ".#nixosConfigurations.laptop.config.system.build.toplevel.drvPath"
```

- [ ] **Step 6: Commit**

```bash
git add systems/nixos flake.nix
git commit -m "feat: add nixosConfigurations.nixos consolidating laptop/desktop

New NixOS config copies systems/desktop and adds modules/apps imports.
Existing laptop and desktop outputs left in place for now."
```

---

## Task 4: Add `darwinConfigurations.darwin` (generic Mac baseline)

**Rationale:** Stand up the generic Darwin output so `work` can extend it in Task 5.

**Files:**
- Create: `systems/darwin/configuration.nix`
- Create: `systems/darwin/home.nix`
- Modify: `flake.nix` (add `darwinConfigurations.darwin`)

- [ ] **Step 1: Create `systems/darwin/configuration.nix`**

Copy from `systems/work/configuration.nix` verbatim. The current work configuration.nix is generic enough — homebrew tap registration is in `flake.nix`, not `configuration.nix`.

```nix
{pkgs, ...}: {
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ git vim wget curl ];

  users.users.graytonw = {
    name = "graytonw";
    home = "/Users/graytonw";
  };

  fonts.packages = with pkgs;
    [ nerd-fonts.fira-code ];

  services.aerospace.enable = false;
  services.aerospace.settings = {
	accordion-padding = 300;
	default-root-container-layout = "tiles";
	default-root-container-orientation = "auto";
	key-mapping = {
	  preset = "qwerty";
	};
  };

  programs.fish.enable = true;
  system.stateVersion = 5;
}
```

- [ ] **Step 2: Create `systems/darwin/home.nix`**

```nix
{ config, pkgs, ... }: {
  home.username = "graytonw";
  home.homeDirectory = "/Users/graytonw";

  imports = [
    ../../modules/base
    ../../modules/dev
    ../../modules/apps
  ];

  programs.fish.shellAliases = {
    nixup = "darwin-rebuild switch --flake ~/repos/nixos-config/#darwin";
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
```

- [ ] **Step 3: Add `darwinConfigurations.darwin` to `flake.nix`**

In the `outputs` block, immediately before `darwinConfigurations.work`, add:

```nix
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
        ({config, ...}: {
            homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
      ];
    };
```

- [ ] **Step 4: Verify the new output builds**

```bash
darwin-rebuild build --flake ".#darwin"
```

Expected: builds cleanly.

Verify existing work config still builds:

```bash
darwin-rebuild build --flake ".#work"
```

- [ ] **Step 5: Commit**

```bash
git add systems/darwin flake.nix
git commit -m "feat: add darwinConfigurations.darwin generic baseline

New generic Darwin config with shell + dev + apps + nix-homebrew skeleton.
The work config will extend this in a follow-up commit."
```

---

## Task 5: Rewrite `work` to extend `darwin`

**Rationale:** Switch `darwinConfigurations.work` to reuse `systems/darwin/configuration.nix` and have `systems/work/home.nix` import `../darwin/home.nix`. After this, `systems/work/configuration.nix` is unreferenced (deleted in Task 7).

**Files:**
- Modify: `systems/work/home.nix` (rewrite to extend darwin's home)
- Modify: `flake.nix` (`darwinConfigurations.work` to use `./systems/darwin/configuration.nix`)

- [ ] **Step 1: Rewrite `systems/work/home.nix`**

The new file imports `../darwin/home.nix` and adds only the work-specific overrides. Preserve the work-specific bits exactly: mise package, slack-cli fish helpers, mise interactiveShellInit, work tmux bindings, work git email.

```nix
{config, pkgs, lib, ...}: {
  imports = [ ../darwin/home.nix ];

  home.packages = [ pkgs.mise ];

  programs.git.settings.user.email = "grayton.ward@apollographql.com";

  programs.fish = {
    shellAliases.nixup = lib.mkForce
      "darwin-rebuild switch --flake ~/repos/nixos-config/#work";

    functions = {
      slack-send.body = ''
	cat /dev/stdin | string collect | begin echo '```'; cat; echo '```'; end | slack-cli send $to -
      '';
      slack-send.argumentNames = "to";

      slack-tui.body = ''
	set -l SESSION_NAME "slack-tui"
	set -l COMMAND "slack-cli tui"

	tmux-session $SESSION_NAME

	set -l WINDOW_IDEX 1
	set -l WINDOW_IDEX (tmux list-windows -t $SESSION_NAME -F "#{window_index}:#{window_name}" | grep "^$WINDOW_INDEX:" | cut -d: -f2)

	if not tmux list-panes -t "$SESSION_NAME:$WINDOW_NAME" -F "#{pane_title}" | grep -q "$COMMAND"
          tmux send-keys -t "$SESSION_NAME:$WINDOW_INDEX" "$COMMAND" Enter
        end
      '';
    };

    interactiveShellInit = ''
source "$(brew --prefix)/share/google-cloud-sdk/path.fish.inc"
set -gx MISE_SHELL fish
set -gx __MISE_ORIG_PATH $PATH

function mise
  if test (count $argv) -eq 0
    command /etc/profiles/per-user/graytonw/bin/mise
    return
  end

  set command $argv[1]
  set -e argv[1]

  if contains -- --help $argv
    command /etc/profiles/per-user/graytonw/bin/mise "$command" $argv
    return $status
  end

  switch "$command"
  case deactivate shell sh
    # if help is requested, don't eval
    if contains -- -h $argv
      command /etc/profiles/per-user/graytonw/bin/mise "$command" $argv
    else if contains -- --help $argv
      command /etc/profiles/per-user/graytonw/bin/mise "$command" $argv
    else
      source (command /etc/profiles/per-user/graytonw/bin/mise "$command" $argv |psub)
    end
  case '*'
    command /etc/profiles/per-user/graytonw/bin/mise "$command" $argv
  end
end

function __mise_env_eval --on-event fish_prompt --description 'Update mise environment when changing directories';
    /etc/profiles/per-user/graytonw/bin/mise hook-env -s fish | source;

    if test "$mise_fish_mode" != "disable_arrow";
        function __mise_cd_hook --on-variable PWD --description 'Update mise environment when changing directories';
            if test "$mise_fish_mode" = "eval_after_arrow";
                set -g __mise_env_again 0;
            else;
                /etc/profiles/per-user/graytonw/bin/mise hook-env -s fish | source;
            end;
        end;
    end;
end;

function __mise_env_eval_2 --on-event fish_preexec --description 'Update mise environment when changing directories';
    if set -q __mise_env_again;
        set -e __mise_env_again;
        /etc/profiles/per-user/graytonw/bin/mise hook-env -s fish | source;
        echo;
    end;

    functions --erase __mise_cd_hook;
end;

__mise_env_eval
if functions -q fish_command_not_found; and not functions -q __mise_fish_command_not_found
    functions -e __mise_fish_command_not_found
    functions -c fish_command_not_found __mise_fish_command_not_found
end

function fish_command_not_found
    if string match -qrv -- '^(?:mise$|mise-)' $argv[1] &&
        /etc/profiles/per-user/graytonw/bin/mise hook-not-found -s fish -- $argv[1]
        /etc/profiles/per-user/graytonw/bin/mise hook-env -s fish | source
    else if functions -q __mise_fish_command_not_found
        __mise_fish_command_not_found $argv
    else
        __fish_default_command_not_found_handler $argv
    end
end
'';
  };

  programs.tmux = {
    extraConfig = ''
      bind C-q run-shell "fish -c 'tmux-session /Users/graytonw/repos/monorepo'"
      bind C-w run-shell "fish -c 'tmux-session /Users/graytonw/repos/apollo-argo'"
      bind C-e run-shell "fish -c 'tmux-session /Users/graytonw/repos/scratch'"
    '';
  };
}
```

Note: the `home.username`, `home.homeDirectory`, `home.stateVersion`, and `programs.home-manager.enable` come from the imported `../darwin/home.nix`. The `nixup` alias must use `lib.mkForce` because `darwin/home.nix` already sets it.

- [ ] **Step 2: Update `darwinConfigurations.work` in `flake.nix`**

Change `./systems/work/configuration.nix` to `./systems/darwin/configuration.nix` in the `darwinConfigurations.work.modules` list. Everything else stays the same (work keeps its extra homebrew taps).

```nix
    darwinConfigurations.work = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./systems/darwin/configuration.nix          # was: ./systems/work/configuration.nix
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
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
	    	"deskflow/homebrew-tap" = deskflow;
		"graytonio/homebrew-brief" = brief;
            };
          };
        }

       ({config, ...}: {
           homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
       })
      ];
    };
```

- [ ] **Step 3: Build and verify**

```bash
darwin-rebuild build --flake ".#work"
```

Expected: builds cleanly. The result should be functionally equivalent to before (same packages, same fish config, same git email).

- [ ] **Step 4: Commit**

```bash
git add systems/work/home.nix flake.nix
git commit -m "refactor: work extends darwin baseline

work/home.nix now imports darwin/home.nix and adds only work-specific
overrides (mise, slack-cli helpers, work tmux bindings, apollographql
git email). work output reuses darwin's configuration.nix."
```

---

## Task 6: Add portable `shell-linux` and `shell-darwin` outputs

**Rationale:** Stand up the new richer portable HM config with cross-platform username/homeDir logic, two flake outputs (one per system), and verify both before removing old `graytonio`.

**Files:**
- Modify: `systems/shell/home.nix` (rewrite)
- Modify: `flake.nix` (add `shell-linux`, `shell-darwin` outputs alongside existing `graytonio`)

- [ ] **Step 1: Rewrite `systems/shell/home.nix`**

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

  # Mac convention is ~/repos/nixos-config; Linux convention is ~/nixos-config
  programs.fish.shellAliases.nixup =
    if pkgs.stdenv.isDarwin
    then "home-manager switch --flake ~/repos/nixos-config/#shell-darwin"
    else "home-manager switch --flake ~/nixos-config/#shell-linux";

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
```

- [ ] **Step 2: Add `shell-linux` and `shell-darwin` outputs to `flake.nix`**

Inside the `outputs` block, replace the existing `homeConfigurations."graytonio" = ...` block with both old (kept temporarily) and new entries. Use a `let` binding for the helper:

```nix
  outputs = { nixpkgs, nix-darwin, home-manager, hyprland, hyprpanel, nur, nix-homebrew, homebrew-core, homebrew-cask, deskflow, brief, ... }@inputs:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    mkHome = system: module: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      modules = [ module ];
    };
  in
  {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

    homeConfigurations."graytonio" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./systems/shell/home.nix
      ];
    };

    homeConfigurations."shell-linux"  = mkHome "x86_64-linux"   ./systems/shell/home.nix;
    homeConfigurations."shell-darwin" = mkHome "aarch64-darwin" ./systems/shell/home.nix;

    # ... rest of outputs unchanged
```

Note: `homeConfigurations.graytonio` keeps using `pkgs = nixpkgs.legacyPackages.x86_64-linux` (Linux-only) for backward compat until Task 7 deletes it. The new `shell-linux` is functionally identical to it but uses the new `mkHome` helper for clarity.

- [ ] **Step 3: Build the darwin variant locally (we're on Mac)**

```bash
nix build --no-link ".#homeConfigurations.shell-darwin.activationPackage" --print-out-paths
```

Expected: prints a `/nix/store/...` path. The `pkgs.stdenv.isDarwin` branches resolve to the Mac values.

- [ ] **Step 4: Eval-check the linux variant**

```bash
nix eval --raw ".#homeConfigurations.shell-linux.activationPackage.drvPath"
```

Expected: prints a `/nix/store/...` path. (Building this on Mac would attempt cross-compilation; eval is enough for now. Full build can happen on a Linux host later.)

- [ ] **Step 5: Verify legacy `graytonio` still builds**

```bash
nix build --no-link ".#homeConfigurations.graytonio.activationPackage" --print-out-paths
```

Expected: still prints a path. (It uses the same `systems/shell/home.nix` which is now richer than before, but should still evaluate fine on Linux.)

- [ ] **Step 6: Commit**

```bash
git add systems/shell/home.nix flake.nix
git commit -m "feat: add portable shell-linux and shell-darwin outputs

systems/shell/home.nix now imports base + dev + apps and selects
username/homeDirectory based on pkgs.stdenv.isDarwin. New flake outputs
homeConfigurations.shell-linux (x86_64-linux) and .shell-darwin
(aarch64-darwin). The legacy .graytonio output is left in place
temporarily; removed in the next task."
```

---

## Task 7: Remove old outputs and orphan files

**Rationale:** Clean up. Delete the now-redundant outputs (`graytonio`, `laptop`, `desktop`), delete the orphan `systems/laptop/`, `systems/desktop/`, and `systems/work/configuration.nix`, and update README.

**Files:**
- Delete: `systems/laptop/`
- Delete: `systems/desktop/`
- Delete: `systems/work/configuration.nix`
- Modify: `flake.nix` (remove `homeConfigurations.graytonio`, `nixosConfigurations.laptop`, `nixosConfigurations.desktop`)
- Modify: `README.md`

- [ ] **Step 1: Delete orphan system directories**

```bash
git rm -r systems/laptop
git rm -r systems/desktop
git rm systems/work/configuration.nix
```

- [ ] **Step 2: Remove old outputs from `flake.nix`**

Delete these blocks from the `outputs` body:

- `homeConfigurations."graytonio" = ...`
- `nixosConfigurations.laptop = ...`
- `nixosConfigurations.desktop = ...`

The remaining outputs are exactly: `formatter.x86_64-linux`, `homeConfigurations."shell-linux"`, `homeConfigurations."shell-darwin"`, `nixosConfigurations.nixos`, `darwinConfigurations.darwin`, `darwinConfigurations.work`.

The `let` binding for `pkgs = nixpkgs.legacyPackages.x86_64-linux;` is no longer used (it only fed `graytonio`); remove it. Keep `mkHome`.

- [ ] **Step 3: Rewrite `README.md`**

Replace the existing README content with the new four-configuration documentation:

```markdown
# Nix Configuration

This repository contains my Nix-based system configurations and modules for NixOS, macOS (via nix-darwin), and standalone home-manager. It uses the Nix Flakes system for managing dependencies and configurations.

## Repository Structure

- `modules/`: Reusable home-manager modules organized by tier
  - `base/`: Always-on shell, editor, and CLI tools (every config imports this)
  - `dev/`: Programming languages and dev tooling
  - `apps/`: Cross-platform GUI apps (ghostty, firefox)
  - `desktop/`: Linux-only desktop environment (Hyprland, Linux GUI apps)
  - `gaming/`: NixOS-only gaming tooling

- `systems/`: System-specific configurations
  - `shell/`: Portable home-manager for any non-NixOS Linux or Mac host
  - `nixos/`: Full NixOS host (Hyprland desktop)
  - `darwin/`: Generic nix-darwin baseline (shell + homebrew skeleton)
  - `work/`: Apollo work Mac (extends `darwin/` with work-specific overrides)

## The Four Configurations

### `shell` — portable home-manager (Linux + Mac)

For non-NixOS hosts where you only want user-level configuration.

```bash
nix run home-manager/master -- switch --flake .#shell-linux    # on Linux
nix run home-manager/master -- switch --flake .#shell-darwin   # on Mac
home-manager switch --flake .#shell-linux                      # subsequent rebuilds
```

### `nixos` — full NixOS host

```bash
sudo nixos-rebuild switch --flake .#nixos
```

### `darwin` — generic Mac with homebrew baseline

```bash
nix run nix-darwin -- switch --flake .#darwin    # bootstrap
darwin-rebuild switch --flake .#darwin           # subsequent rebuilds
```

### `work` — Apollo work Mac (extends `darwin`)

```bash
darwin-rebuild switch --flake .#work
```

## Requirements

- Nix with Flakes support (`experimental-features = nix-command flakes`)
- For `nixos`/`darwin`/`work`: root or sudo for system-wide rebuilds
- For `shell`: no root required

## License

MIT.
```

- [ ] **Step 4: Verify final flake outputs**

```bash
nix flake show --json | jq 'keys'
```

Expected output (or similar):

```json
[
  "darwinConfigurations",
  "formatter",
  "homeConfigurations",
  "nixosConfigurations"
]
```

Then verify each:

```bash
nix eval --raw ".#nixosConfigurations.nixos.config.system.build.toplevel.drvPath"
nix build --no-link ".#darwinConfigurations.darwin.config.system.build.toplevel" --print-out-paths
nix build --no-link ".#darwinConfigurations.work.config.system.build.toplevel" --print-out-paths
nix build --no-link ".#homeConfigurations.shell-darwin.activationPackage" --print-out-paths
nix eval --raw ".#homeConfigurations.shell-linux.activationPackage.drvPath"
```

Expected: all five print paths. None of `graytonio`/`laptop`/`desktop` exist any more.

- [ ] **Step 5: Confirm no stale references remain**

```bash
grep -RE "modules/(shell|programs|programming|gui|wm)" --include="*.nix" .
grep -RE "systems/(laptop|desktop)" --include="*.nix" .
grep -E "graytonio.*homeConfigurations|nixosConfigurations\.(laptop|desktop)" flake.nix
```

Expected: all three commands print nothing (no output).

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor: remove old outputs and update README

Remove homeConfigurations.graytonio, nixosConfigurations.laptop,
nixosConfigurations.desktop, systems/laptop/, systems/desktop/, and
systems/work/configuration.nix. Update README to describe the four
configurations: shell-{linux,darwin}, nixos, darwin, work."
```

---

## Post-implementation verification

After Task 7 commits, the final state should match this checklist. Run from the repo root:

- [ ] `nix flake show` lists exactly: `formatter.x86_64-linux`, `homeConfigurations.{shell-linux, shell-darwin}`, `nixosConfigurations.nixos`, `darwinConfigurations.{darwin, work}`.
- [ ] `darwin-rebuild build --flake .#darwin` succeeds.
- [ ] `darwin-rebuild build --flake .#work` succeeds.
- [ ] `nix build --no-link .#homeConfigurations.shell-darwin.activationPackage` succeeds.
- [ ] `nix eval --raw .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath` succeeds.
- [ ] `nix eval --raw .#homeConfigurations.shell-linux.activationPackage.drvPath` succeeds.
- [ ] `git status` clean.
- [ ] `tree -L 2 modules` shows `apps/`, `base/`, `dev/`, `desktop/`, `gaming/` only — no `shell/`, `programs/`, `programming/`, `gui/`, `wm/`.
- [ ] `tree -L 2 systems` shows `shell/`, `nixos/`, `darwin/`, `work/` only — no `laptop/`, `desktop/`.

If any of these fails, fix before declaring done.

## Future follow-ups (out of scope here)

- Switch the `work` config to import `dev/apollo.nix` instead of inlining the mise/google-cloud-sdk fish setup. (The two copies will drift.)
- Decide whether `deskflow/homebrew-tap` and `graytonio/homebrew-brief` should move to the generic `darwin` taps.
- Add a homebrew-cask-based Firefox option for Macs (currently uses Nix-installed Firefox via `programs.firefox`).
- Consider removing `services.aerospace` from `systems/darwin/configuration.nix` if it's no longer used (`enable = false` now, only the settings remain).
