{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    metropolis = {
      url = "github:matze/mtheme";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, metropolis, ... }: (
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Packages
        builderHeader = ''
          #!${pkgs.bash}/bin/bash
          set -exuo pipefail
          mkdir -p $out
        '';

        tex = with pkgs; (texlive.combine {
          inherit (texlive) scheme-medium pgfopts;
        });

        beamer-metropolis = derivation (with pkgs; {
          inherit system;
          name = "beamer-metropolis";
          builder = (writeShellScript "builder.sh" (builderHeader + ''
            cp -a $inp/* .
            make sty
            cp *.sty $out/
          ''));
          inp = "${metropolis}";
          PATH = lib.makeBinPath [ bash coreutils gnumake tex ];
        });

        # Env vars
        FONT_PATH = "${pkgs.fira}/share/fonts/opentype";
        THEME_PATH = "${beamer-metropolis}";
      in rec {
        packages.inftheory-slides-pdf = derivation (with pkgs; {
          inherit system FONT_PATH THEME_PATH;
          name = "inftheory-slides-pdf";
          builder = writeShellScript "builder.sh" (builderHeader + ''
            cd $inp
            make pdf OUTFILE=$out/inftheory-slides.pdf
          '');
          inp = ./.;
          PATH = lib.makeBinPath [ bash coreutils gnumake tex pandoc librsvg ];
        });
        defaultPackage = packages.inftheory-slides-pdf;

        devShell = pkgs.mkShell {
          inherit system FONT_PATH THEME_PATH;
          buildInputs = with pkgs; [
            tex
            pandoc
            gnome.librsvg
            inotify-tools
          ];
        };
      }
    )
  );
}
