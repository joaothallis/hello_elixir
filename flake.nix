{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        erl = pkgs.beam.interpreters.erlang_27;
        erlangPackages = pkgs.beam.packagesWith erl;
        elixir = erlangPackages.elixir;
      in
      {
        packages =
          let
            version = "0.1.0";
            src = ./.;
            mixFodDeps = with pkgs; import ./mix_deps.nix { inherit lib beamPackages; };
            # mixFodDeps = erlangPackages.fetchMixDeps {
            #   inherit version src;
            #   pname = "ri-elixir-deps";
            #   sha256 = "sha256-8aSihmaxNOadMl7+0y38B+9ahh0zNowScwvGe0npdPw=";
            # };
            translatedPlatform =
              {
                aarch64-darwin = "macos-arm64";
                aarch64-linux = "linux-arm64";
                armv7l-linux = "linux-armv7";
                x86_64-darwin = "macos-x64";
                x86_64-linux = "linux-x64";
              }
              .${system};
          in
          rec {
            # inner expression
            default = erlangPackages.mixRelease {
              inherit version src mixFodDeps;
              pname = "ravensiris-web";

              preInstall = ''
                ${elixir}/bin/mix release
              '';
            };
          };
      }
    );
}
