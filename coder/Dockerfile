FROM nixos/nix:2.35.2

RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

ENV USER=coder
ENV HOME=/home/coder
ENV PATH="/home/coder/.nix-profile/bin:${PATH}"
RUN mkdir -p "$HOME" "$HOME/.local/state/nix/profiles"

# The Coder agent's host-stats collector (github.com/coder/clistat) requires
# a valid /etc/*-release file to report workspace CPU/memory stats; the
# nixos/nix base image doesn't ship one. Without it, the agent's "resources
# monitor" routine errors out and tears down the entire agent connection
# (not just the stats display) -- confirmed empirically: the agent
# authenticated and connected, then immediately disconnected in a loop with
# "no valid /etc/<distrib>-release file found".
RUN printf 'NAME="NixOS Container"\nID=nixos\nVERSION_ID="unstable"\nPRETTY_NAME="NixOS Container"\n' > /etc/os-release

WORKDIR /flake
COPY . .

RUN nix run --impure /flake#homeConfigurations.shell-linux.activationPackage

# home-manager's programs.fish.enable makes fish available and configures it,
# but standalone home-manager (no full NixOS) can't write /etc/passwd -- that
# stays whatever the base image shipped (bash) unless set explicitly here.
# Confirmed empirically: a real workspace's `coder ssh` / web terminal landed
# in bash even with fish fully installed and configured. awk (not chsh/usermod,
# which this minimal image may not have) rewrites just the shell field on the
# root passwd entry.
RUN FISH_BIN="/home/coder/.nix-profile/bin/fish" && \
    grep -qxF "$FISH_BIN" /etc/shells 2>/dev/null || echo "$FISH_BIN" >> /etc/shells && \
    awk -v shell="$FISH_BIN" 'BEGIN{FS=OFS=":"} $1=="root"{$7=shell} {print}' /etc/passwd > /etc/passwd.new && \
    mv /etc/passwd.new /etc/passwd

WORKDIR $HOME
