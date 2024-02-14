# NixOS System Configurations

This repository contains my NixOS system configurations.

To update the system use:

```
nix flake update
sudo nixos-rebuild switch --flake /etc/nixos#murks
```

To update a remote system use:
```
sudo nixos-rebuild switch --flake 'github:samularity/nixos-config#box'
```
