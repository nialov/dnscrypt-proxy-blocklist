(
  { inputs, ... }:

  {
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
            yamllint = {
              enable = true;
            };
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
              ${pkgs.wget}/bin/wget https://download.dnscrypt.info/blacklists/domains/mybase.txt --output-document blocklists/mybase.txt
              if [ "$(wc -l < blocklists/mybase.txt)" -eq 0 ]; then
                  echo "Error: Blocklist is empty."
                  exit 1
              fi
              # Add and commit file. Make the script work even while in GitHub Actions AI!
            '';
          };
        };
      };

  }
)
