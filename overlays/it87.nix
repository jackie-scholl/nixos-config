self: super: {
  linuxPackages = super.linuxPackages // {

    it87 = super.linuxPackages.it87.overrideAttrs (old: rec {
      src = super.fetchFromGitHub {
        owner = "gamanakis";
        repo = "it87";
        #branch = "it8688E";
        rev = "2b8b4febb760410c01a9d50032ece85eccd7926f";
        sha256 = "1paqk1djimwqz9vr0b1x6jr7v50wxdk71i7vwpbn772vyv2j55z0";
      };
    });
  };
}
