{ pkgs, lib, ... }:

{
	boot.kernelModules = [ "rtl8821ce"  "it87" "coretemp" "aklsdjfjasldki"];
	boot.kernelPackages = pkgs.linuxPackages;
	boot.extraModulePackages = [ pkgs.linuxPackages.it87 pkgs.linuxPackages.rtl8821ce ]; 
	boot.kernelParams = ["acpi_enforce_resources=lax"];
	boot.kernelPatches = lib.singleton {
		name = "hidbattery";
		patch = null;
		extraConfig = ''
			HID_BATTERY_STRENGTH n
		'';
	};
	  
	boot.loader = {
		efi.canTouchEfiVariables = true;
		grub.enable = true;
		grub.efiSupport = true;
		grub.useOSProber = true;
		grub.device = "nodev"; #"/dev/disk/by-path/pci-0000\:01\:00.0-nvme-1";
		grub.extraConfig = "acpi_enforce_resources=lax";
		systemd-boot.enable = true;
	};
	# Set the font earlier in the boot process. Copied from Becca
	console = {
		earlySetup = true;
		keyMap = "us";
	};
}
