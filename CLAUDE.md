# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Applying Changes

`nh` is configured with `NH_FLAKE=/home/snuppy/.dots`, so from anywhere:

```sh
nh os switch        # apply and make boot default
nh os test          # apply without changing boot entry
nh os boot          # stage for next boot only
```

To target a specific host explicitly:

```sh
nh os switch /home/snuppy/.dots#snp-des1nix
```

After editing, push to both remotes: (only known to work on snp-des1nix due to
uncertain git remote states on the other hosts)

```sh
git push origin main && git push local-server main
```

## Nix Formatting

Use `alejandra` for formatting `.nix` files (it is installed system-wide via
`cli-common.nix`).

## Architecture

This is a flake-based NixOS configuration managing multiple hosts for the user
`snuppy`.

### Active Hosts

| Hostname    | User   | Desktop |
| ----------- | ------ | ------- |
| snp-des1nix | snuppy | GNOME   |
| snp-lap1nix | snuppy | GNOME   |
| snp-des2nix | mend   | (none)  |

`snp-nuc1nix` and `snp-des3nix` are defined but commented out in `flake.nix`.

### Shared Modules (root level)

- `all-common.nix` — sops-nix config, git, locale (Europe/Oslo / nb_NO),
  tailscale, SSH, `users.mutableUsers = false`
- `cli-common.nix` — defines the `mycli.username` option; sets nushell as
  default shell; configures nvf (neovim), starship, carapace, yazi, and CLI
  packages
- `gnome.nix` — GDM + GNOME desktop with extensions (tiling-shell, gsconnect,
  etc.)
- `style.nix` — stylix theming (rose-pine scheme, 0xProto Nerd Font, spicetify)
- `personal-common.nix` — snuppy user definition, pipewire, libvirt/QEMU, Steam,
  Thunar, flatpak, `nh` with auto-gc
- `snuppy-home-common.nix` — home-manager config shared across snuppy hosts:
  kitty, GTK/Adwaita icons, weathr, common packages
- `vscode-home.nix` — VS Code home-manager config (imported by snuppy hosts)
- `mend-home.nix` — home-manager config for the `mend` user

### Per-Host Directories

Each host directory (`snp-*/`) contains:

- `configuration.nix` — host-specific NixOS config
- `hardware-configuration.nix` — auto-generated hardware config
- `hardware-myextra.nix` — extra hardware config (GPU, kernel modules, etc.)
  where present
- `snuppy-home.nix` — imports `snuppy-home-common.nix` (and `vscode-home.nix`)
  and sets `home.stateVersion`

### Secrets

`secrets.yaml` is encrypted with sops/age. Keys are derived from each host's SSH
host key (`/etc/ssh/ssh_host_ed25519_key`) and the user's age key. The
`.sops.yaml` file lists all recipient keys. To edit secrets:

```sh
sops secrets.yaml
```

Secrets are available at runtime under `/run/secrets/`. User passwords use
`neededForUsers = true` and land in `/run/secrets-for-users/`.

### Flake Inputs

| Input         | Purpose                        |
| ------------- | ------------------------------ |
| nixpkgs       | nixos-25.11                    |
| home-manager  | release-25.11                  |
| sops-nix      | secrets management             |
| nvf           | neovim configuration framework |
| stylix        | system-wide theming            |
| spicetify-nix | Spotify theming                |
| weathr        | weather widget home module     |
