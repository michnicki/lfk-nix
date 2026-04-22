# lfk-nix

Nix flake for [lfk](https://github.com/janosmiko/lfk) — a lightning-fast, keyboard-focused terminal UI for navigating and managing Kubernetes clusters.

## Usage

### Run without installing

```bash
nix run codeberg:tmichnicki/lfk-nix
```

### Install via `nix profile`

```bash
nix profile install codeberg:tmichnicki/lfk-nix
```

### Use in your own flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    lfk-nix.url = "codeberg:tmichnicki/lfk-nix";
  };

  outputs = { nixpkgs, lfk-nix, ... }: {
    # add lfk to a NixOS or home-manager config
    environment.systemPackages = [
      lfk-nix.packages.${system}.default
    ];
  };
}
```

### Overlay

```nix
nixpkgs.overlays = [ lfk-nix.overlays.default ];
# pkgs.lfk is then available
```

## Supported systems

| System           | Architecture |
|------------------|--------------|
| `x86_64-linux`   | Linux x86-64 |
| `aarch64-linux`  | Linux ARM64  |
| `x86_64-darwin`  | macOS x86-64 |
| `aarch64-darwin` | macOS ARM64  |

## Updating

To update to a new lfk release, change `version` in `flake.nix`, then update the `hash` and `vendorHash` fields:

1. Set both hashes to `pkgs.lib.fakeHash`
2. Run `nix build` — the error output shows the correct `hash`
3. Update `hash`, run `nix build` again — the error output shows the correct `vendorHash`
4. Update `vendorHash`, run `nix build` to confirm
5. **Note:** If the build fails with a Go version error, check the `postPatch` section in `flake.nix` and ensure the `sed` command matches the Go version in the new release's `go.mod`.

## License

MIT
