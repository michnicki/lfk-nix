{
  description = "Lightning Fast Kubernetes navigator - keyboard-focused TUI for managing K8s clusters";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      version = "0.10.4";
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.buildGoModule {
            pname = "lfk";
            inherit version;

            src = pkgs.fetchFromGitHub {
              owner = "janosmiko";
              repo = "lfk";
              rev = "v${version}";
              hash = "sha256-av5px1ASLpN8i/p2QX7Ja1Lw6eAsPXoSfOD6MIFMxkI=";
            };

            vendorHash = "sha256-GfJr3jtG+GhV7AHgM0EjPe+bFqdIRkHpjaylu753cGI=";

            env.CGO_ENABLED = "0";

            excludedPackages = [ "internal/version" ];

            postPatch = ''
              sed -i 's/^go 1\.26\.2/go 1.26.1/' go.mod
            '';

            overrideModAttrs = (_: {
              postPatch = ''
                sed -i 's/^go 1\.26\.2/go 1.26.1/' go.mod
              '';
            });

            ldflags = [
              "-s"
              "-w"
              "-X github.com/janosmiko/lfk/internal/version.Version=v${version}"
            ];

            meta = with pkgs.lib; {
              description = "Lightning Fast Kubernetes navigator - keyboard-focused TUI for managing K8s clusters";
              homepage = "https://github.com/janosmiko/lfk";
              license = licenses.mit;
              mainProgram = "lfk";
              platforms = platforms.unix;
            };
          };
        });

      overlays.default = final: prev: {
        lfk = self.packages.${prev.stdenv.hostPlatform.system}.default;
      };
    };
}
