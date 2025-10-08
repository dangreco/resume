{
  description = "dangreco/resume environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          pkgs,
          ...
        }:
        {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              # nix
              nil
              nixd
              nixfmt

              # utils
              git
              act
              just

              # typst
              typst
              font-awesome
            ];

            shellHook = ''
              export TYPST_FONT_PATHS="${pkgs.font-awesome}/share/fonts/opentype:${pkgs.font-awesome}/share/fonts/truetype"
            '';
          };
        };
    };
}
