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
    ./retiolum.nix
  ];

  networking.retiolum.ipv4 = "10.243.0.42";  # optional
  networking.retiolum.ipv6 = "42:0:2c4b:29bf:c7e4:6775:339e:2a0";
  services.tinc.networks.retiolum = {
    rsaPrivateKeyFile = "/home/sam/retiolum-cfg/rsa_key.priv";
    ed25519PrivateKeyFile = "/home/sam/retiolum-cfg/ed25519_key.priv";
  };

  nix.nixPath = ["nixpkgs=${pkgs.path}" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.tmp.useTmpfs  = true; #make sure /tmp is in ram

  networking.hostName = "murks"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

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

  # Configure console keymap
  console.keyMap = "de-latin1-nodeadkeys";

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
      git
      bintools
      vlc
      signal-desktop
      firefox
      unrar
      libsForQt5.ark
            
      (pkgs.writers.writeDashBin "code" ''
      NIX_LD_LIBRARY_PATH=${NIX_LD_LIBRARY_PATH} NIX_LD=${NIX_LD} ${myVSCODE}/bin/code "$@"
      '')

    ];
  };

  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "sam";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;



  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    htop
    python3
    usbutils
    file
  ];


  services.udev = {
      extraRules = ''
        SUBSYSTEM=="usb",GROUP="dialout", MODE="0664", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001"
        SUBSYSTEM=="usb",GROUP="dialout", MODE="0664", ATTRS{idVendor}=="15a2", ATTRS{idProduct}=="0054"
      '';
  };  


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
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
