{
  lib,
  config,
  pkgs,
  modulesPath,
  ...
}:
let
  diskLabel = "nixos";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
    ];
    boot.growPartition = true;

    boot.loader.grub = {
      enable = true;
      device = "/dev/vda";
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/${diskLabel}";
        fsType = "ext4";
        autoResize = true;
      };
    };

    system.build.diskImage = import "${modulesPath}/../lib/make-disk-image.nix" {
      inherit lib config pkgs;

      format = "qcow2";
      partitionTableType = "legacy+gpt";
      label = diskLabel;
    };

    services.qemuGuest.enable = true;
  };
}
