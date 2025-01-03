{ pkgs, config, ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
  };

  swapDevices = [ ];

  boot.kernelModules = [
    #"acpi_call" # Useful for power management, especially for turning off the discrete GPU if needed.
    #"i915" # Intel graphics driver for integrated graphics (needed for boot display).
    #"iwlwifi" # Wifi drivers
    #"btusb" # I tink I need it to make bluetooth work optimally :shrug:
  ];

  boot.initrd = {
    verbose = false;
    kernelModules = [];
    availableKernelModules = [
      "xhci_pci" # USB 3.0 support.
      "ahci" # SATA controller driver (essential for your internal SSD).
      "usb_storage" # If you use USB drives frequently.
      "usbhid" # USB keyboard and mouse support (typically needed for external peripherals).
      "sd_mod" # SCSI disk support (includes SATA drives).
      # "dm_mod" # Required for LVM/encryption.
      # "thunderbolt" # Thunderbolt devices.
    ];
  };

  hardware = {
    cpu.intel.updateMicrocode = true;  # Installs and applies Intel microcode updates for CPU fixes and security patches.
    enableRedistributableFirmware = true;  # Enables firmware that isn't part of the open-source kernel, required for some hardware devices.

    graphics = {
      enable = true; # Mesa
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver  # Video Acceleration API (VAAPI) driver for Intel hardware to accelerate video processing.
        intel-media-driver  # Additional media driver for Intel hardware, improving video encoding/decoding.
      ];
    };

    trackpoint.enable = true;  # Enables support for the TrackPoint (the small red dot used as a pointing device on ThinkPads).
    trackpoint.emulateWheel = true; # Enable scrolling while holding the middle mouse button.
    #hardware.trackpoint.sensitivity = 200;  # Optionally adjusts the sensitivity of the TrackPoint device, if uncommented.
  };

  powerManagement.cpuFreqGovernor = "performance";
}
