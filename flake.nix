{
  description = "Lightning Fast Kubernetes navigator - keyboard-focused TUI for managing K8s clusters";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      version = "0.14.13";
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
              hash = "sha256-AofhuNzhVmyMXLdZYSKBrQ2BwN5kbaGkHJ9nu9NPaQ0=";
            };

            vendorHash = "sha256-WYx/eMArAsiyfEvrBZmTfK2ABxX2X1VQEtDCxC+UyP8=";

            env.CGO_ENABLED = "0";

            excludedPackages = [ "internal/version" ];

            postPatch = ''
              sed -i 's/^go 1\.26\.[0-9]*/go 1.26.1/' go.mod
            '';

            overrideModAttrs = (_: {
              postPatch = ''
                sed -i 's/^go 1\.26\.[0-9]*/go 1.26.1/' go.mod
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
