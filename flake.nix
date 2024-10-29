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
    {
      nixosConfigurations = {
        ocean = nixpkgs.lib.nixosSystem {
          inherit pkgs;
          modules = [ (import ./nixos/configuration.nix) ];
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
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
            mixNixDeps = with pkgs; with beamPackages; import ./mix_deps.nix { inherit lib beamPackages; };
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
            default = erlangPackages.mixRelease {
              inherit version src mixNixDeps;
              pname = "hello";

              preInstall = ''
                ${elixir}/bin/mix release --no-deps-check
              '';
            };
            nixosModule =
              {
                config,
                lib,
                pkgs,
                ...
              }:
              let
                cfg = config.services.hello;
                user = "hello";
                dataDir = "/var/lib/hello";
              in
              {
                options.services.hello = {
                  enable = lib.mkEnableOption "hello";
                };
                config = lib.mkIf cfg.enable {
                  users.users.${user} = {
                    isSystemUser = true;
                    group = user;
                    home = dataDir;
                    createHome = true;
                  };
                  users.groups.${user} = { };

                  systemd.services = {
                    hello = {
                      description = "Start up the homepage";
                      wantedBy = [ "multi-user.target" ];
                      script = ''
                        # Elixir does not start up if `RELEASE_COOKIE` is not set,
                        # even though we set `RELEASE_DISTRIBUTION=none` so the cookie should be unused.
                        # Thus, make a random one, which should then be ignored.
                        export RELEASE_COOKIE=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 20)

                        ${default}/bin/hello eval Hello.hello
                      '';
                      serviceConfig = {
                        User = user;
                        WorkingDirectory = "${dataDir}";
                        Group = user;
                      };

                      environment = {
                        # Disable Erlang's distributed features
                        RELEASE_DISTRIBUTION = "none";
                        # Additional safeguard, in case `RELEASE_DISTRIBUTION=none` ever
                        # stops disabling the start of EPMD.
                        ERL_EPMD_ADDRESS = "127.0.0.1";
                        # Home is needed to connect to the node with iex
                        HOME = "${dataDir}";
                        # PORT = toString cfg.port;
                      };
                    };
                  };
                };
              };

          };
      }
    );
}
