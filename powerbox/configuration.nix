{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./disk-config.nix
      ./home-assi.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [ "ip=dhcp" ];
  boot.initrd = {
    availableKernelModules = [ "e1000e" ];
    systemd.users.root.shell = "/bin/cryptsetup-askpass";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
        authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      };
    };
  };


services.openssh = {
  enable = true;
  settings.PasswordAuthentication = false;
  settings.KbdInteractiveAuthentication = false;
};

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF04U/97+gvDNY7q2dp8MrzEtU7Idbuf5hbJHUtCfixJ sam"
  ];
   networking.hostName = "powerbox"; # Define your hostname.


networking.interfaces.eno1.useDHCP = false;
networking.interfaces.eno1.ipv4.addresses = [{
  address = "192.168.178.5";
  prefixLength = 24; # e.g., 24 for 255.255.255.0
}];
networking.defaultGateway = "192.168.178.1";

networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
networking.firewall.allowedTCPPorts = [ 8080 ];

services.adguardhome = {
  enable = true;
  mutableSettings = true;
  settings = {
    http = {
      # You can select any ip and port, just make sure to open firewalls where needed
      address = "0.0.0.0:3688";
    };
    dns = {
      bind_hosts = [ "192.168.178.5" ];
      upstream_dns = [
        # Example config with quad9
       #"9.9.9.9#dns.quad9.net"
        #"149.112.112.112#dns.quad9.net"
        #"149.112.112.112"
        #"9.9.9.9"
       #"1.1.1.1"
        "192.168.178.1" # to resolve .lan domains, configured in openwrt to use 9.9.9.9
      ];
    };
    filtering = {
      protection_enabled = true;
      filtering_enabled = true;
      parental_enabled = false;  # Parental control-based DNS requests filtering.
      safe_search = {
        enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
      };
    };
    # The following notation uses map
    # to not have to manually create {enabled = true; url = "";} for every filter
    # This is, however, fully optional
    filters = map(url: { enabled = true; url = url; }) [
      "https://easylist.to/easylist/easylist.txt" # easylist germany
      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_6.txt"  # Dandelion Sprout's Game Console Adblock List
      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_60.txt"  # HaGeZi's Xiaomi Tracker Blocklist
      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
      "https://filters.adtidy.org/extension/ublock/filters/11.txt" # adtidy android
      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_59.txt" # adguard DNS
      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_3.txt" # peter Lowes Blocklist
      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_51.txt" # HaGeZi Pro++
    ];
  };
};
networking.firewall = {
    interfaces.eno1 = {
        allowedTCPPorts = [ 3688 ];
        allowedUDPPorts = [ 53 ];
    };
};





  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  # };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.11"; # dont touch
}
