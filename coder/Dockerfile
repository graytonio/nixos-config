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

# headless-linux, not shell-linux: no GUI applications (Ghostty, Firefox, VS
# Code) that a container can never display. Measured against this flake's own
# nixpkgs pin, that takes the profile closure from 8.94 GB to 6.59 GB. It also
# removes the ncurses/Ghostty terminfo collision documented in
# modules/base/posix-tools.nix from this image entirely.
#
# No --impure needed: systems/headless/home.nix hardcodes username and home
# directory, where systems/shell/home.nix reads them from $USER/$HOME via
# builtins.getEnv. The ENV lines above still matter at container runtime, they
# are just no longer an input to the build.
#
# Built to a stable out-link rather than `nix run` because the path is needed
# again at *runtime*. The workspace home directory is a PVC that is seeded from
# this image exactly once, on first boot; it is never re-seeded. So the
# home-manager dotfile symlinks it captures freeze pointing at whichever
# home-manager-files store path the seeding image had, and every later image
# rebuild changes that hash and leaves them dangling -- fish, starship, tmux and
# nvim all silently lose their config while still starting normally. Confirmed
# empirically: ~/.config/fish/config.fish pointed at a store path absent from
# the running image. coder-templates/nix-dev/main.tf re-runs
# /hm-activation/activate on every workspace start to re-point them (~500ms,
# idempotent); this out-link is the stable path it looks for.
RUN nix build --out-link /hm-activation /flake#homeConfigurations.headless-linux.activationPackage \
    && /hm-activation/activate

# home-manager's programs.fish.enable makes fish available and configures it,
# but standalone home-manager (no full NixOS) can't write /etc/passwd -- that
# stays whatever the base image shipped (bash) unless set explicitly here.
# Confirmed empirically: a real workspace's `coder ssh` / web terminal landed
# in bash even with fish fully installed and configured.
#
# Pure POSIX sh + grep only, no awk/sed/chsh/usermod -- confirmed empirically
# that this minimal nixos/nix base image doesn't have awk (CI failure: "awk:
# command not found"), so anything beyond the handful of tools already proven
# present earlier in this Dockerfile (grep, printf, mkdir) can't be assumed
# available either. ${OLDLINE%:*} is a shell parameter-expansion builtin
# (strips the shortest trailing ":*" match, i.e. just the final passwd field),
# not an external command.
RUN FISH_BIN="/home/coder/.nix-profile/bin/fish" && \
    grep -qxF "$FISH_BIN" /etc/shells 2>/dev/null || echo "$FISH_BIN" >> /etc/shells && \
    OLDLINE="$(grep '^root:' /etc/passwd)" && \
    NEWLINE="${OLDLINE%:*}:${FISH_BIN}" && \
    grep -v '^root:' /etc/passwd > /etc/passwd.new && \
    echo "$NEWLINE" >> /etc/passwd.new && \
    mv /etc/passwd.new /etc/passwd

WORKDIR $HOME
