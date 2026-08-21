FROM nixos/nix:2.35.2

RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

ENV USER=coder
ENV HOME=/home/coder
ENV PATH="/home/coder/.nix-profile/bin:${PATH}"
RUN mkdir -p "$HOME" "$HOME/.local/state/nix/profiles"

WORKDIR /flake
COPY . .

RUN nix run --impure /flake#homeConfigurations.shell-linux.activationPackage

WORKDIR $HOME
