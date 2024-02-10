# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# to update your system use
# sudo nix flake lock --update-input nixpkgs -I /etc/nixos
# sudo nixos-rebuild switch --flake /etc/nixos#murks
#

{ config, pkgs, ... }:

{

  imports = [ 
    ./hardware-configuration.nix
    ../retiolum.nix
#    ../common.nix
  ];

  networking.retiolum.ipv4 = "10.243.0.42";  # optional
  networking.retiolum.ipv6 = "42:0:2c4b:29bf:c7e4:6775:339e:2a0";
  services.tinc.networks.retiolum = {
    rsaPrivateKeyFile = "/home/sam/retiolum-cfg/rsa_key.priv";
    ed25519PrivateKeyFile = "/home/sam/retiolum-cfg/ed25519_key.priv";
  };

  networking.interfaces."tinc.retiolum".ipv4.addresses = [ { address = config.networking.retiolum.ipv4; prefixLength = 16; } ];
  networking.interfaces."tinc.retiolum".ipv6.addresses = [ { address = config.networking.retiolum.ipv6; prefixLength = 16; } ];


  nix.nixPath = ["nixpkgs=${pkgs.path}" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.tmp.useTmpfs  = false; #make sure /tmp is in ram
  #boot.tmp.tmpfsSize = "95%";

  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "murks"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;


  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  
  # Configure keymap in X11
  services.xserver = {
    layout = "de";
    xkbVariant = "nodeadkeys";
  };



  # Enable CUPS to print documents.
  services.printing.enable = true;

  #enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

programs.nix-ld.enable = true;
programs.ssh.startAgent = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sam = {
    isNormalUser = true;
    description = "sam";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];


    packages = with pkgs; let 

        nix-ld-so = pkgs.runCommand "ld.so" {} ''
          ln -s "$(cat '${pkgs.stdenv.cc}/nix-support/dynamic-linker')" $out
        '';

          myVSCODE = 
          (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            bbenoist.nix
            rust-lang.rust-analyzer
            vadimcn.vscode-lldb
            ms-vscode.hexeditor
            ms-python.python
            ms-vscode.cpptools
            ms-vscode.cmake-tools
            twxs.cmake
            vscode-extensions.streetsidesoftware.code-spell-checker
            tomoki1207.pdf
            bierner.markdown-mermaid

          ]++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [

        {
          name = "html-preview-vscode";
          publisher = "tht13";
          version = "0.2.5";
          sha256 = "sha256-22CeRp/pz0UicMgocfmkd4Tko9Avc96JR9jJ/+KO5Uw=";
        }


        {
          name = "platformio-ide";
          publisher = "platformio";
          version = "3.0.0";
          sha256 = "sha256-+0haTk/xbPoustJVE81tI9X8gcfiamx8nZBm7kGGY6c=";
        }

        {

          name = "code-spell-checker-german";
          publisher = "streetsidesoftware";
          version = "2.2.1";
          sha256 = "sha256-F0ykTfFAZSqWfntYKWWEgtUyLimBT0Q0fiE219/YqGs=";
        }

        ];
      });

    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
        stdenv.cc.cc
        libusb1
        zlib
      ];
    NIX_LD = toString nix-ld-so;


    in  [
      wireshark
      kate
      google-chrome
      thunderbird
      bintools
      vlc
      signal-desktop
      firefox
      unrar
      libsForQt5.ark
      gparted
      element-desktop
      pulseview
      inkscape

      (pkgs.writers.writeDashBin "code" ''
      NIX_LD_LIBRARY_PATH=${NIX_LD_LIBRARY_PATH} NIX_LD=${NIX_LD} ${myVSCODE}/bin/code "$@"
      '')

    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "sam";





  services.udev = {
      extraRules = ''
        SUBSYSTEM=="usb",GROUP="dialout", MODE="0664", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001"
        SUBSYSTEM=="usb",GROUP="dialout", MODE="0664", ATTRS{idVendor}=="15a2", ATTRS{idProduct}=="0054"
      '';
  };  

#used for gio mount dav:
services.gvfs.enable = true;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  #networking.firewall.enable = false;


#    networking.firewall = {
#      enable = true;
#      allowedTCPPorts = [ 23 50000 52000 ];
#      allowedUDPPorts = [ 50000 50001 ];
#      allowedUDPPortRanges = [
#          { from = 19997; to = 19999; }
#      ];
#  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
