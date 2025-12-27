{config, pkgs, ...}: {
  imports = [
    ../../modules/shell
    ../../modules/programs/nvim
  ];

  home.packages = [
    pkgs.mise
  ];

  programs.fish = {
    shellAliases = {
      nixup = "sudo darwin-rebuild switch --flake ~/repos/nixos-config/#work";
    };

    functions = {
      slack-send.body = ''
	cat /dev/stdin | string collect | begin echo '```'; cat; echo '```'; end | slack-cli send $to -
      '';
      slack-send.argumentNames = "to";
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

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
