(
  { inputs, ... }:

  {
    imports = [ inputs.nix-extra.flakeModules.custom-pre-commit-hooks ];
    perSystem =

      {
        config,
        system,
        pkgs,
        lib,
        ...
      }:
      let
        mkNixpkgs =
          nixpkgs:
          import nixpkgs {
            inherit system;
            overlays =

              [
                inputs.nix-extra.overlays.default
              ];
            config = {
              allowUnfree = true;
            };
          };

      in
      {
        _module.args.pkgs = mkNixpkgs inputs.nixpkgs;
        devShells = {
          default = pkgs.mkShell {
            buildInputs = lib.attrValues { inherit (pkgs) nixfmt-rfc-style; };
            shellHook = config.pre-commit.installationScript;
          };

        };

        pre-commit = {
          check.enable = true;
          settings.hooks = {
            nixfmt-rfc-style.enable = true;
            nbstripout.enable = true;
            shellcheck.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            rstcheck.enable = true;
            commitizen.enable = true;
            ruff = {
              enable = true;
            };
          };

        };
        legacyPackages = pkgs;

        packages = {
          update-blocklist = pkgs.writeShellApplication {
            name = "update-blocklist";
            text = ''
              git checkout -b "update-blocklist-$(date +%Y-%m-%d-%H-%M-%S)"
              if ! git diff --quiet HEAD --; then
                  echo "Error: Uncommitted changes detected. Please commit or stash them before running this script."
                  exit 1
              fi
              mkdir -p blocklists/
              ${pkgs.wget}/bin/wget https://download.dnscrypt.info/blacklists/domains/mybase.txt --output-document blocklists/mybase.txt
              # Check if the file actually changed
              if git diff --quiet blocklists/mybase.txt; then
                  echo "No changes detected in the blocklist. Exiting."
                  exit 0
              fi
              git add blocklists/mybase.txt
              git commit -m "chore: update blocklist"
              git push origin HEAD
            '';
          };
        };
      };

  }
)
