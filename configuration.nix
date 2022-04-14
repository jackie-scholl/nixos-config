# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
	unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
	overlays = import ./overlays ;
	mercury = import ./mercury ;
in 
{
	imports = [
		<nixos-hardware/framework>
		./hardware-configuration.nix # Include the results of the hardware scan.
		./imports/packages.nix
		./imports/boot.nix
		(mercury.recommended {
		      vpnConfigPath = ./secrets/pritunl/pritunl.ovpn;
		    })
		(mercury.wm {})
	];

	nixpkgs.config.allowBroken = true;

	documentation = {
		dev.enable = true;
		nixos.includeAllModules = true;
	};

	system.copySystemConfiguration = true;
	system.extraSystemBuilderCmds = "ln -s ${./.} $out/full-config";

	services.hardware.bolt.enable = true; # thunderbolt

	#hardware.opengl.driSupport32Bit = true;
	#hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
	#hardware.pulseaudio.support32Bit = true;

	# The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    #networking.interfaces.enp0s13f0u3u4.useDHCP = true;
    networking.interfaces.wlp170s0.useDHCP = true;
    networking.networkmanager.enable = true;

	fonts = {
		enableDefaultFonts = true;
		fonts = [ (pkgs.iosevka.override {
			privateBuildPlan = {
				family = "Iosevka Jackie custom";

				design = [
					"sans"
					"expanded"
				];
			};
	  		set = "jackiecustom";
		}) ];
		fontconfig.defaultFonts = {
			emoji = [ "Twitter Color Emoji" "Noto Color Emoji" ];
			monospace = [ "Iosevka Jackie custom extended" "Hack" "Iosevka"] ;
		};
	};

	# Select internationalisation properties.
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.inputMethod = {
		enabled = "ibus";
		ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
	};

	environment.sessionVariables = {
		TERMINAL = [ "konsole" ];
		EDITOR = [ "micro" ];
	};

    location.latitude = 42.762;
    location.longitude = -71.226;
    
	services.redshift = {
	    enable = true;
	};

	services.udev.extraRules = ''
# Rule for all ZSA keyboards
SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
SUBSYSTEM=="usb", ATTR{idVendor}=="20d6", MODE="0666"

	'';

	  services.xserver = {
	    enable = true;
	    displayManager.defaultSession = "none+xmonad";
	    windowManager = {
	      xmonad = {
	        enable = true;
	        enableContribAndExtras = true;
	      };
	    };
	    videoDrivers = [
	    	"displaylink"
	    	"modesetting"
	    ];
	  };

	sound.enable = true;
	hardware.pulseaudio.enable = true;
	hardware.bluetooth.enable = true;

	# Set your time zone.
	time.timeZone = "America/New_York";
	time.hardwareClockInLocalTime = true;

    users.groups.plugdev = {};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.jackie = {
		isNormalUser = true;
		description = "Jackie Scholl";
		extraGroups = [ 
			"wheel" # Enable ‘sudo’ for the user.
			"audio"
			"networkmanager"
			"plugdev"
		];
		shell = pkgs.fish;
	};

	security.sudo.wheelNeedsPassword = false;

	nix = {
		trustedBinaryCaches = [
			"https://cache.nixos.org"
			"https://all-hies.cachix.org"
		];
		binaryCachePublicKeys = [
			"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
			"all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
		];
		trustedUsers = [ "root" "jackie" ];
	};

	nixpkgs.config.allowUnfree = true;
	nixpkgs.overlays = lib.attrValues overlays;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "20.09"; # Did you read the comment?
}
