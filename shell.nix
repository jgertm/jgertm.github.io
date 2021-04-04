let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    gnumake entr pandoc haskellPackages.pandoc-sidenote
    # tectonic
  ];
}
