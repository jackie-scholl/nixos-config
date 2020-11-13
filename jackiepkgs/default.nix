{ pkgs ? import <nixpkgs> { } };
let
	allPkgs = pkgs // jackiepkgs;
	callPackage = path: overrides:
	    let f = import path;
	    in f
	    ((builtins.intersectAttrs (builtins.functionArgs f) allPkgs) // overrides);

	  jackiepkgs = {
	  	inherit callPackage;
	  	# packages go here
	  };
in jackiepkgs
