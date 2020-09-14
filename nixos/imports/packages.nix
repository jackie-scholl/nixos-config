{ pkgs, ... }:

{
environment.systemPackages = with pkgs; [
	dmenu
    firefox
    fish
    git
	linuxPackages.it87
    lm_sensors
	stalonetray

	(pkgs.makeAutostartItem {
	    name = "firefox";
	    package = pkgs.firefox;
	})

	#taffybar
	
	#(pkgs.haskellPackages.taffybar.override { packages = (p : p.haskellPackage.harfbuzz); })
    #(pkgs.haskellPackages.ghcWithPackages (self : [
 #       self.mtl
 #       self.xmonad
 #       self.taffybar
 #       self.cabal-install
 #       #self.harfbuzz
 #       self.ghc
 #   ]))

	vlc
    wget
    xclip
    xdotool
    xmobar
    zoom

    #(import ./imports/emacs.nix { inherit pkgs; })
  ];
}
