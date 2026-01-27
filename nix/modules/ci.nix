{ self, lib, ... }:
{

  flake.actions-nix = {
    pre-commit.enable = true;
    defaults = {
      jobs = {
        timeout-minutes = 60;
        runs-on = "ubuntu-latest";
      };
    };
    workflows =

      let
        checkoutStep = {
          uses = "actions/checkout@v5";
        };
        installNixStep = {
          # uses = "DeterminateSystems/nix-installer-action@v9";
          uses = "cachix/install-nix-action@v31";
        };

      in
      {
        ".github/workflows/main.yaml" = {
          on = {
            push = { };
            workflow_dispatch = { };
            # pull_request = { };
          };

          jobs = {
            "nix-flake-check".steps = [
              checkoutStep
              installNixStep
              {
                name = "Run nix flake checks";
                run = "nix flake check";
              }
            ];
          };

        };
        ".github/workflows/update-blocklist.yaml" = {
          on = {
            push = { };
            workflow_dispatch = { };
            schedule = [
              {
                cron = "0 0 * * *";
              }
            ];
            # pull_request = { };
          };

          jobs = {
            "update-blocklist".steps = [
              checkoutStep
              installNixStep
              {
                name = "Make directory";
                run = "mkdir -p blocklists/";
              }
              {
                name = "Download latest";
                run = "wget https://download.dnscrypt.info/blacklists/domains/mybase.txt --output-document blocklists/mybase.txt";
              }
            ];
          };

        };

      };
  };
}
