{ pkgs ? import <nixpkgs> {}}:

let
	myEmacs = (pkgs.emacs.override {
		withGTK3 = true;
		withGTK2 = false;
	}).overrideAttrs (attrs : {
		postInstall = (attrs.postInstall or "") + ''
			  rm $out/share/applications/emacs.desktop
			'';
	});
	
	emacsWithPackages = (pkgs.emacsPackagesGen myEmacs).emacsWithPackages;
in

emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [
	magit   # ; Integrate git <C-x g>
	#lsp-racket
]) ++ (with epkgs.melpaPackages; [
	lsp-mode
	which-key
	lsp-haskell
]) ++ (with epkgs.elpaPackages; [
	#beacon   # ; Highlight cursor when scrolling
]) ++ [
	#pkgs.notmuch # ; from main packages set
])



