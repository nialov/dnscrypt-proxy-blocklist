{ inputs, ... }:
{

  imports = [
    inputs.actions-nix.flakeModules.default
  ];
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

          permissions = {
            contents = "write";
            pull-requests = "write";
          };
          jobs = {
            "update-blocklist".steps = [
              checkoutStep
              installNixStep
              {
                name = "Set up git and branch";
                run = ''
                  git config --global user.name "GitHub Actions"
                  git config --global user.email "actions@github.com"
                '';
              }
              {
                name = "Update blocklist";
                run = "nix run .#update-blocklist";
              }
              {
                name = "Create Pull Request";
                run = ''
                  gh pr create --title "chore: update blocklist" --body "Automated update of the blocklist."
                '';
                env = {
                  GH_TOKEN = "\${{ secrets.GITHUB_TOKEN }}";
                };
              }
            ];
          };

        };

      };
  };
}
