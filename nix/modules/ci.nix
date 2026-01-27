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
          };

          jobs = {
            "update-blocklist".steps = [
              checkoutStep
              installNixStep
              {
                name = "Set up git";
                run = ''
                # We do not want to push to master. Rather make branch and pull request AI!
                  git config --global user.name "GitHub Actions"
                  git config --global user.email "actions@github.com"
                '';
              }
              {
                name = "Update blocklist";
                run = "nix run .#update-blocklist";
              }
            ];
          };

        };

      };
  };
}
