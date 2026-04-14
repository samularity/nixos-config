
{ config, pkgs, libs, ... }:
let
  ha_confdir = "/var/lib/homeassistant-docker";
  esp_confdir  = "/var/lib/esp-home-docker";
in {

# --- Networking & Firewall ---
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      8123 # Home Assistant UI
      6052 # ESPHome UI
    ];
    # ESPHome often uses UDP for device discovery/mDNS
    allowedUDPPorts = [ 5353 ]; 
  };


    systemd.timers."podman-auto-update".wantedBy = [ "timers.target" ];
    virtualisation.podman.autoPrune = {
        enable = true;
        dates = "weekly";
    };
    
    virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
        volumes = [ "${ha_confdir}:/config" ];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/home-assistant/home-assistant:latest";
        imageAutoUpdate = true;
        extraOptions = [ 
        "--network=host" 
        "--device=/dev/ttyUSB0:/dev/ttyUSB0"
        ];
    };

    containers.esphome = {
        volumes = [ "${esp_confdir}:/config" ];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/esphome/esphome:beta";
        imageAutoUpdate = true;
        extraOptions = [ 
        "--network=host" 
        "--privileged"
        ];
    };

    };

}
