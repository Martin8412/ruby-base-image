FROM nixos/nix

RUN nix-channel --update

RUN nix-build -A ruby '<nixpkgs>'