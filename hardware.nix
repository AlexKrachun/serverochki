{ modulesPath, ... }:
{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/b4617946-d732-41a4-94de-72615414c227";
      fsType = "ext4";
    };

  zramSwap = {
    enable = true;
    memoryPercent = 200;
  };
}
