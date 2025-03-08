
{ config, pkgs, libs, ... }:
let
  ha_confdir = "/var/lib/homeassistant-docker";
  esp_confdir  = "/var/lib/esp-home-docker";
in {

    networking.firewall.allowedTCPPorts = [ 6052 8123 ];

    virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
        volumes = [ "${ha_confdir}:/config" ];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/home-assistant/home-assistant:latest";
        extraOptions = [ 
        "--network=host" 
        "--device=/dev/ttyUSB0:/dev/ttyUSB0"
        ];
    };

    containers.esphome = {
        volumes = [ "${esp_confdir}:/config" ];
        environment.TZ = "Europe/Berlin";
        image = "ghcr.io/esphome/esphome:latest";
        extraOptions = [ 
        "--network=host" 
        "--privileged"
        ];
    };




    };

}
