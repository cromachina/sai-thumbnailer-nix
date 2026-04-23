{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      libsai = pkgs.stdenv.mkDerivation {
        name = "libsai";
        src = pkgs.fetchFromGitHub {
          owner = "Wunkolo";
          repo = "libsai";
          rev = "f8eae5189ac20c0cf41922b8cca726ff3e05ef39";
          hash = "sha256-LULwg/TPrw0sRcUl8YUqw7Glta9l2Q4Y+1jRnnUk9qw=";
        };
        patches = [ ./Thumbnail-Sai2.cpp.patch ];
        nativeBuildInputs = [ pkgs.cmake ];
        installPhase = ''
          mkdir -p $out/bin
          cp Thumbnail-Sai2 $out/bin/thumbnail-sai2
        '';
      };
      thumbnailer = pkgs.writeTextFile {
        name = "sai2-thumbnailer";
        destination = "/share/thumbnailers/sai2.thumbnailer";
        text = ''
          [Thumbnailer Entry]
          Exec=${libsai}/bin/thumbnail-sai2 %i %o
          MimeType=application/sai2;
        '';
      };
    in {
      packages.default = thumbnailer;
    }
  );
}