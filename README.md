# NixOS System Configurations

This repository contains my NixOS system configurations.

To update the system use:

```
sudo nix flake lock --update-input nixpkgs -I /etc/nixos
sudo nixos-rebuild switch --flake /etc/nixos#murks
```