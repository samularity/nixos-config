{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-SAMSUNG_MZ7LN256HAJQ-000L7_S3S7NX0M346934";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                #works:
                format = "ext4";

                #won't work:
                #format = "bcachefs";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}