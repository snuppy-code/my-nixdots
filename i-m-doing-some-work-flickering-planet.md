# Auth rework: passwordless-ish SSH + sudo across hosts

## Context

Currently working on `snp-des2nix` over SSH from `snp-des1nix`/`snp-lap1nix` is annoying because:

1. **SSH itself prompts for password** — `mend@snp-des2nix` has no `authorizedKeys.keys` set. The SK key on snuppy's yubikey is only authorized on the `git` system user, not on `mend`. So every `ssh snp-des2nix` triggers a password prompt.
2. **Sudo prompts for password** every 2h (current `timestamp_timeout=120`).
3. **Locally** snuppy still types the master password after login for sudo. `snp-lap1nix` has `pam_u2f` set up for login+sudo, `snp-des1nix` doesn't.
4. **GNOME keyring** is implicitly enabled (via `services.desktopManager.gnome.enable`) and auto-unlocks via PAM, exposing a session-wide Secrets bus to any process — exactly the "security theater" snuppy called out.
5. Friend (TBD username — call him `<frienduser>` for now) needs root on `snp-des2nix`, will mostly SSH in, sometimes physical. He runs NixOS + sops and has a yubikey of the same kind.

Goal: minimize password typing without weakening the security gate. Use the SK-yubikey as the real auth factor: tap-per-SSH (already the case) and tap-per-sudo (via `pam_ssh_agent_auth` on the server, `pam_u2f` on the desktops), with a short sudo cache so back-to-back commands don't all re-tap.

## Design

### A. `snp-des2nix` — SSH + sudo via SK key

**SSH login:** Authorize snuppy's SK key (and later friend's) on the relevant user account.

Edit `snp-des2nix/configuration.nix`:

```nix
users.users.mend = {
  isNormalUser = true;
  extraGroups = ["networkmanager" "wheel"];
  hashedPasswordFile = config.sops.secrets.mend-password.path;
  openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNz...AABHNzaDo= snuppy.code@pm.me"
    # friend's SK key goes on his own user, not here
  ];
};
```

Also explicitly disable password SSH globally on this host (it's a server on tailscale; key-only is fine):

```nix
services.openssh.settings.PasswordAuthentication = false;
services.openssh.settings.KbdInteractiveAuthentication = false;
```

(Keep the existing `Match user git` block as-is.)

**Sudo via forwarded agent + SK key:** Add to `snp-des2nix/configuration.nix`:

```nix
security.pam.sshAgentAuth = {
  enable = true;
  authorizedKeysFiles = ["/etc/ssh/authorized_keys.d/%u"];
};
security.pam.services.sudo.sshAgentAuth = true;
```

The NixOS module auto-adds `SSH_AUTH_SOCK` to sudo's `env_keep`. Because the authorized key is an SK key, every signature requires a yubikey tap → trojan on `snp-des2nix` literally cannot escalate without snuppy's physical tap, even with the forwarded socket.

**Sudo cache:** Override the 120min default — too long for a multi-user server. Drop to 15s so consecutive sudos in the same shell don't all re-tap, but anything longer than that asks again. In `snp-des2nix/configuration.nix` (overrides `all-common.nix`):

```nix
security.sudo.extraConfig = lib.mkForce ''
  Defaults timestamp_timeout=0.25
'';
```

### B. Add friend as a user on `snp-des2nix`

Once `<frienduser>` provides his age public key, SSH public key (must be SK-backed for the same security guarantee), and a hashed password:

1. Edit `.sops.yaml`: add `&<frienduser> ageXYZ...` under `users:` and include him in the `secrets.yaml` recipient group.
2. Re-encrypt: `sops updatekeys secrets.yaml`.
3. Add `<frienduser>-password` to `secrets.yaml`.
4. In `snp-des2nix/configuration.nix`:
   ```nix
   sops.secrets."<frienduser>-password".neededForUsers = true;
   users.users.<frienduser> = {
     isNormalUser = true;
     extraGroups = ["wheel" "networkmanager"];
     hashedPasswordFile = config.sops.secrets."<frienduser>-password".path;
     openssh.authorizedKeys.keys = [
       "sk-ssh-ed25519@openssh.com ... <frienduser>@<his-host>"
     ];
   };
   ```

`pam_ssh_agent_auth` is system-wide and already covers him. With `wheel` he can sudo via his own SK-key tap. Sudo audit log shows `<frienduser>` vs `mend` distinctly.

Sops recipient note: he'll be able to decrypt `secrets.yaml` (including snuppy's password hash). Snuppy stated this is acceptable. If that ever changes, split into a per-host or per-section secrets file later — out of scope now.

### C. `snp-des1nix` and `snp-lap1nix` — local sudo via yubikey

`snp-lap1nix` already has `services.pcscd.enable` and `pam_u2f` for login+sudo. The NixOS `u2fAuth = true` option installs `pam_u2f` as **sufficient**, so it tries yubikey first and falls back to password if no key is present (or registration is missing). This is exactly the right behavior for `snp-des1nix` (yubikey often unplugged because no front USB-C).

Apply the same config to `snp-des1nix/configuration.nix` — uncomment the block that's already there as a comment:

```nix
services.pcscd.enable = true;
security.pam.services = {
  login.u2fAuth = true;
  sudo.u2fAuth = true;
};
```

Also reduce sudo cache to 15s on both desktops via `all-common.nix` (current 120min applies to all hosts). Change in `all-common.nix`:

```nix
security.sudo.extraConfig = ''
  Defaults timestamp_timeout=0.25
'';
```

Since this is in `all-common.nix`, it applies to all three hosts (and the `mkForce` override in B is no longer needed — drop step B's `mkForce` block once this lands).

**Add SSH keys for snuppy on `snp-des1nix`:** Currently `snp-des1nix/configuration.nix` has `users.users.snuppy.openssh.authorizedKeys.keys = []`. Add snuppy's SK key plus `mend@snp-des2nix` for symmetry with lap1nix:

```nix
users.users.snuppy.openssh.authorizedKeys.keys = [
  "sk-ssh-ed25519@openssh.com AAAAGnNrLXNz...AABHNzaDo= snuppy.code@pm.me"
  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5...P9 mend@snp-des2nix"
];
```

**Manual post-deploy step (per host, per yubikey):** snuppy registers the key for `pam_u2f` on each desktop:

```sh
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys   # first key; use >> to append more
```

### D. Disable GNOME keyring

In `gnome.nix`, add:

```nix
services.gnome.gnome-keyring.enable = lib.mkForce false;
security.pam.services.gdm-password.enableGnomeKeyring = lib.mkForce false;
security.pam.services.login.enableGnomeKeyring = lib.mkForce false;
```

(`gnome-keyring` is normally pulled in implicitly by the GNOME meta-module; we have to `mkForce` to win the priority. Add `lib` to the module's function signature.)

This kills auto-unlock and the session-wide Secrets bus. `programs.ssh.startAgent = true` (set in `personal-common.nix`) continues to provide the SSH agent independently.

### E. SSH agent forwarding from desktops → server

`pam_ssh_agent_auth` on `snp-des2nix` needs the agent socket reachable from there, which means `ForwardAgent yes` for that host on the client side. Add to `programs.ssh.extraConfig` in **both** `snp-des1nix/configuration.nix` and `snp-lap1nix/configuration.nix`:

```
Host snp-des2nix
  Hostname snp-des2nix.tailf46592.ts.net
  Port 22
  User mend
  ForwardAgent yes
```

Lateral-movement note: forwarded agent on `snp-des2nix` is reachable by anything running as `mend` (and root) on that host. Because the only key being signed is an SK key requiring physical tap, an attacker holding the socket cannot use it without snuppy actively tapping at that moment. This is the cheap-and-effective version of the agent-forwarding-mitigation story. Do NOT add a non-SK private key to the agent on the desktops — that would undo this guarantee.

### F. Bitwarden vault unlock (out of NixOS scope, mentioned for completeness)

Bitwarden's Firefox extension doesn't natively support yubikey-tap-to-unlock (yubikey is only for 2FA on initial login, not for the vault PIN/master). Practical options:

- **Easiest (recommended):** In the extension's Settings → Security, set a numeric **Unlock PIN** and check "Lock with master password on browser restart" = OFF. You'll type a short PIN on restart instead of the long master password. Vault still locks on timeout.
- **Better:** Install the Bitwarden desktop app and enable "Browser integration"; the extension can then unlock via the desktop app's biometric/PIN flow. NixOS side: add `bitwarden-desktop` to `personal-common.nix` `environment.systemPackages`.
- True yubikey-tap-to-unlock would require a non-standard wrapper (e.g., a script that uses `ykchalresp` to derive the master password from a stored seed). Not building this now.

## Critical files

- `all-common.nix` — reduce `timestamp_timeout` to `0.25`.
- `snp-des2nix/configuration.nix` — add `mend.openssh.authorizedKeys`, `services.openssh.settings.PasswordAuthentication = false`, `KbdInteractiveAuthentication = false`, `pam.sshAgentAuth`, `pam.services.sudo.sshAgentAuth`. Later, append `<frienduser>` block (step B).
- `snp-des1nix/configuration.nix` — populate `snuppy.openssh.authorizedKeys`, uncomment the pcscd + pam_u2f block, add `Host snp-des2nix` with `ForwardAgent yes`.
- `snp-lap1nix/configuration.nix` — add `ForwardAgent yes` to the existing `Host snp-des2nix` block.
- `gnome.nix` — add `lib` arg, disable `gnome-keyring` and PAM keyring hooks (mkForce).
- `.sops.yaml` + `secrets.yaml` — add friend's age key as recipient + his password secret (step B, deferred until he provides keys).
- `personal-common.nix` — optionally add `bitwarden-desktop` to packages (step F).

## Implementation order

1. **A + C + E + D + `all-common.nix` timeout change** — all snuppy-only changes. Deploy `snp-des1nix` first (the box you're sitting at), then `snp-lap1nix`, then `snp-des2nix`. For `snp-des2nix` deploy by sshing from a desktop where the new authorized key is already live, **before** flipping `PasswordAuthentication = false` — otherwise risk of lockout.
   - Safer sequence on `snp-des2nix`: first deploy with just the `authorizedKeys` addition and `pam_ssh_agent_auth` enabled (leave password auth on). Verify key login + sudo via agent works. Then second deploy to flip `PasswordAuthentication = false`.
2. **Manual:** `pamu2fcfg` registration on `snp-des1nix` and `snp-lap1nix` for snuppy's yubikey.
3. **Manual:** Bitwarden PIN setup in Firefox extension.
4. **B (friend):** When `<frienduser>` provides his age pubkey + SK-ssh pubkey + hashed password. Add him as sops recipient → `sops updatekeys secrets.yaml` → add secret → add user block → deploy.

## Verification

After each deploy:

- **SSH key login:** From `snp-des1nix` (or `snp-lap1nix`), `ssh snp-des2nix` should tap-yubikey-once and land in a shell with no password prompt. Check `journalctl -u sshd | grep mend` on `snp-des2nix` for `Accepted publickey for mend from ... key SHA256:<fp>`.
- **Sudo via agent:** On `snp-des2nix`, `sudo -k && sudo whoami` should prompt for a yubikey tap (not a password) and print `root`. Within 15s, a second `sudo` runs without re-tap; after, it re-taps.
- **Local sudo:** On each desktop with yubikey plugged in, `sudo -k && sudo whoami` should tap-and-succeed. With yubikey unplugged, it should fall through to a password prompt (test once on snp-des1nix to confirm fallback).
- **No keyring:** After login on either desktop, `pgrep gnome-keyring` returns nothing. `secret-tool lookup foo bar` should fail with "Cannot autolaunch D-Bus without X11" or similar — confirming no session Secrets bus.
- **Lockout safety on snp-des2nix:** Before flipping `PasswordAuthentication = false`, keep one ssh session open as a safety net. Verify keyed login from a second terminal first.
- **Audit attribution:** Once friend is added, `journalctl -u sudo` (or `/var/log/auth.log` equivalent) on snp-des2nix should show distinct usernames for friend vs mend sudo invocations.
