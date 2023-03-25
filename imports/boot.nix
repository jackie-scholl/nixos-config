{ pkgs, lib, ... }:

{
	#boot.kernelPackages = pkgs.linuxKernel.packages.linux_5_19_11;
	boot.kernelPackages = pkgs.linuxPackages_latest;

	boot.loader = {
		efi.canTouchEfiVariables = true;
		grub.enable = true;
		grub.efiSupport = true;
		grub.useOSProber = true;
		grub.device = "nodev"; #"/dev/disk/by-path/pci-0000\:01\:00.0-nvme-1";
		#systemd-boot.enable = true;
	};
	# Set the font earlier in the boot process. Copied from Becca
	console = {
		earlySetup = true;
		keyMap = "us";
	};

	boot.initrd.luks.devices = {
	  root = {
	    device = "/dev/nvme0n1p2";
	    preLVM = true;
	  };
	};
}
