{
  description = "dangreco/resume environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.git-hooks.flakeModule ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          pre-commit.settings.hooks = {
            nixfmt.enable = true;
            yamlfmt.enable = true;
            yamllint.enable = true;
          };

          devShells = {
            default =
              let
                __zed = pkgs.writers.writeJSON "settings.json" { };
              in
              pkgs.mkShell {
                packages =
                  with pkgs;
                  [
                    nil
                    nixd
                    nixfmt
                    pinact
                    go-task
                    typst
                    typstyle
                  ]
                  ++ config.pre-commit.settings.enabledPackages;

                buildInputs = with pkgs; [ font-awesome ];

                shellHook = ''
                  mkdir -p .zed
                  ln -sf ${__zed} .zed/settings.json
                  ${config.pre-commit.shellHook}
                  export TYPST_FONT_PATHS="${pkgs.font-awesome}/share/fonts/opentype:${pkgs.font-awesome}/share/fonts/truetype"
                '';
              };

            ci = pkgs.mkShell {
              packages =
                with pkgs;
                [
                  go-task
                  typst
                  typstyle
                ]
                ++ config.pre-commit.settings.enabledPackages;

              buildInputs = with pkgs; [ font-awesome ];

              shellHook = ''
                ${config.pre-commit.shellHook}
                export TYPST_FONT_PATHS="${pkgs.font-awesome}/share/fonts/opentype:${pkgs.font-awesome}/share/fonts/truetype"
              '';
            };

            release = pkgs.mkShell {
              packages =
                with pkgs;
                [
                  go-task
                  typst
                  typstyle
                ]
                ++ config.pre-commit.settings.enabledPackages;

              buildInputs = with pkgs; [ font-awesome ];

              shellHook = ''
                ${config.pre-commit.shellHook}
                export TYPST_FONT_PATHS="${pkgs.font-awesome}/share/fonts/opentype:${pkgs.font-awesome}/share/fonts/truetype"
              '';
            };
          };
        };
    };
}
