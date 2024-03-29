# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
  overlays = import ./overlays;
  mercury = import ./mercury;
in {
  imports = [
    <nixos-hardware/framework/12th-gen-intel>
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./imports/packages.nix
    ./imports/boot.nix

    (mercury.cache { buildCores = 0; })
    mercury.certs
    (mercury.postgres {
      pkgs = pkgs;
      postgresPackage = pkgs.postgresql_13;
    })
    mercury.aws.aws-mfa
    mercury.wm.xmonad
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall =
      true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall =
      true; # Open ports in the firewall for Source Dedicated Server
  };

  services.postgresql.settings.log_statement = "mod";

  nixpkgs.config.allowBroken = true;

  documentation = {
    dev.enable = true;
    nixos.includeAllModules = true;
  };

  system.copySystemConfiguration = true;
  system.extraSystemBuilderCmds = "ln -s ${./.} $out/full-config";

  /* services.xserver.xautolock = {
       enable = true;
       time = 10;
       notify = 30;
     };
  */

  services.xserver.libinput.touchpad.tapping = true;
  services.hardware.bolt.enable = true; # thunderbolt
  # services.tlp.enable = true;
  networking.firewall.checkReversePath = "loose";

  services.redshift = { enable = true; };

  services.udev.extraRules = ''
    # Rule for all ZSA keyboards
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="20d6", MODE="0666"

    	'';

  networking.networkmanager.enable = true;

  environment.pathsToLink = [ "/share/nix-direnv" ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 30d";
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = [
      (pkgs.iosevka.override {
        privateBuildPlan = {
          family = "Iosevka Jackie custom";
          design = [ "sans" "expanded" ];
          ligations.inherits = "haskell";
        };
        set = "jackiecustom";
      })
    ];
    fontconfig.defaultFonts = {
      emoji = [ "Twitter Color Emoji" "Noto Color Emoji" ];
      monospace = [ "Iosevka Jackie custom extended" "Hack" ];
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
  };

  environment.wordlist.enable = true;

  environment.sessionVariables = {
    TERMINAL = [ "konsole" ];
    EDITOR = [ "micro" ];
  };

  location.latitude = 42.762;
  location.longitude = -71.226;

  powerManagement.cpuFreqGovernor = "performance";

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.fwupd.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";
  #time.timeZone = "America/New_York";
  time.hardwareClockInLocalTime = true;

  users.groups.plugdev = { };

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
  programs.fish.enable = true;

  services.tailscale.enable = true;
  #networking.firewall.allowedUDPPorts = [ 41641 53 ];
  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  security.sudo.wheelNeedsPassword = false;

  hardware.cpu.intel.updateMicrocode = true;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  #nixpkgs.overlays = [
  #     (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  #    ];

  nix = {
    settings.trusted-substituters =
      [ "https://cache.nixos.org" "https://all-hies.cachix.org" ];
    settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
    ];
    settings.trusted-users = [ "root" "jackie" ];
    settings.allow-import-from-derivation = true;
    extraOptions = ''
      			experimental-features = nix-command flakes
            keep-outputs = true
            keep-derivations = true
      		'';
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

