#!/usr/bin/env bash

set -euo pipefail

: "${EDITOR:?EDITOR is not set}"
$EDITOR configuration.nix

if git diff --quiet -- '*.nix'; then
	echo "No changes detected, exiting."
	exit 0
fi

git diff -U2 '*.nix'

echo "Permissions required, you may now have to tap yubikey or enter password."

if sudo -v; then
	echo "Authenticated, rebuilding..."
else
	echo "Authentication failure!"
fi

sudo nixos-rebuild switch --flake . 2>&1 | tee nixos-switch-flake.log | while IFS= read -r line; do
	printf "\rNow: %-80s" "${line:0:80}"
done
echo

if [ "${PIPESTATUS[0]}" -ne 0 ]; then
	echo "NixOS rebuild failed!"
	grep -i --color=always error nixos-switch-flake.log || true
	exit 1
fi

#if ! sudo nixos-rebuild switch --flake . &> nixos-switch-flake.log; then
#	echo "NixOS rebuild failed!"
#	grep -i --color=always error nixos-switch-flake.log || true
#	exit 1
#fi

#sudo nixos-rebuild switch --flake . &>nixos-switch-flake.log || (cat nixos-switch-flake.log | grep --color error && exit 1)

#currentgen=$(nixos-rebuild list-generations | grep current)
pointtime="$(date '+Update config on %A, %Y-%m-%d %T')"
git commit -am "$pointtime"

#notify-send -e "NixOS rebuild OK!" --icon=software-update-available
echo "NixOS rebuild OK!"
