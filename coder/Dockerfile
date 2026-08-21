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

WORKDIR $HOME
