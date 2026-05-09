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
          rev = "ecd0762f6262a5ecf3dbee5d893b550fa17e8a76";
          hash = "sha256-BAHHUJxDZJi4Sh+gg6XEynsOOzofZzS3WtFY67F/Zn8=";
        };
        nativeBuildInputs = [ pkgs.cmake ];
        installPhase = ''
          mkdir -p $out/bin
          cp Thumbnail-Sai1 $out/bin/thumbnail-sai1
          cp Thumbnail-Sai2 $out/bin/thumbnail-sai2
        '';
      };
      sai1-thumbnailer = pkgs.writeTextFile {
        name = "sai1-thumbnailer";
        destination = "/share/thumbnailers/sai1.thumbnailer";
        text = ''
          [Thumbnailer Entry]
          Exec=${libsai}/bin/thumbnail-sai1 %i %o
          MimeType=application/sai1;
        '';
      };
      sai2-thumbnailer = pkgs.writeTextFile {
        name = "sai2-thumbnailer";
        destination = "/share/thumbnailers/sai2.thumbnailer";
        text = ''
          [Thumbnailer Entry]
          Exec=${libsai}/bin/thumbnail-sai2 %i %o
          MimeType=application/sai2;
        '';
      };
      mime-types = pkgs.stdenv.mkDerivation {
        name = "sai-mime-types";
        src = ./.;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p $out/share/mime/packages
          cp $src/sai.xml $out/share/mime/packages/
        '';
      };
    in {
      packages.default = pkgs.symlinkJoin {
        name = "sai-thumbnailers";
        paths = [ sai1-thumbnailer sai2-thumbnailer mime-types ];
      };
    }
  );
}