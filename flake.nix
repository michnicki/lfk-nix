{
  description = "Lightning Fast Kubernetes navigator - keyboard-focused TUI for managing K8s clusters";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      version = "0.17.5";
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
              hash = "sha256-tbd4Loi1NBzJbzKZnX00M+P0/xT0vNwwkFsI32Ho8OE=";
            };

            vendorHash = "sha256-6ggE3voXdV8Yfv9fzdXFTI2zVPMfdPy6D8bWASRMc1g=";

            env.CGO_ENABLED = "0";

            excludedPackages = [ "internal/version" "e2e" ];

            postPatch = ''
              sed -i 's/^go 1\.26\.[0-9]*/go 1.26.1/' go.mod
              # v0.17.x: upstream test hardcodes the dev version; release builds
              # inject the real one via ldflags. Keep the prefix assertion only.
              sed -i '/assert.Contains(t, got, "dev")/d' internal/k8s/fieldmanager_test.go
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
