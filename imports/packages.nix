{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		dmenu
		firefox
		fish
		git
		lm_sensors
		stalonetray
		vlc
		wget
		xclip
		xdotool
		xmobar
		zoom
	];
}
