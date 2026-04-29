{
  disk = {
    main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0077" "dmask=0077" ];
            };
          };
          luks = {
            size = "100%";
            start = "512M";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
    };
  };
  lvm_vg = {
    pool = {
      type = "lvm_vg";
      lvs = {
        swap = {
          size = "8G";
          content = {
            type = "swap";
            discardPolicy = "both";
          };
        };
        root = {
          size = "100%FREE";
          content = {
            type = "btrfs";
            mountpoint = "/";
            mountOptions = [ "compress=zstd" "noatime" ];
          };
        };
      };
    };
  };
}
