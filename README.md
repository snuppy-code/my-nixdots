# Notes to self:
- git push origin main && git push local-server main
- stow -d ~/.dots/stow/ -t ~ -S zed nushell

## First-time setup: GitHub access token

The system flake may reference private GitHub repos as inputs. The token is
provided by sops-nix as a rendered nix.conf fragment, pulled in via `!include?`.
On an already-running machine this is automatic. On a **fresh machine** there is
a chicken-and-egg problem: the token file does not exist until the first
activation, but building a config with a private input needs the token _before_
that.

Bootstrap the very first rebuild by passing the token inline:

    sudo nixos-rebuild switch --flake .#snp-des1nix \
      --option access-tokens "github.com=ghp_REPLACE_WITH_TOKEN"

After this succeeds, `/run/secrets/rendered/nix-access-tokens` exists and is
read automatically on all subsequent rebuilds — drop the `--option` flag from
then on.

Prerequisite: this host's age key (derived from its SSH host key) must already
be a recipient in `.sops.yaml`, and `secrets.yaml` re-encrypted to include it,
or sops-nix cannot decrypt `github-pat` at activation.
