#!/usr/bin/env bash
# Applies this repo's VS Code config on Linux: settings, keybindings and extensions.
#
#   ./install.sh                 # code-server if it's installed, otherwise desktop VS Code
#   ./install.sh code-server     # or force one: code-server | code
#   SKIP_EXTENSIONS=1 ./install.sh
#
# Copies User/*.json over the editor's user folder (replaced files are kept as *.bak), installs the
# .vsix files in vsix/ (themes that aren't on Open VSX, which code-server uses), then every extension
# in extensions.txt. Extensions the marketplace doesn't have (Microsoft-only ones on code-server) fail
# and are skipped. Re-run any time; it only adds.
#
# Not needed for VS Code Remote-SSH or WSL: the remote uses the Windows-side settings and themes, and
# VS Code offers to install workspace extensions on the remote itself.
set -u

repo_directory="$(cd "$(dirname "$0")" && pwd)"
editor="${1:-}"
if [ -z "$editor" ]; then
  if command -v code-server >/dev/null 2>&1; then editor=code-server; else editor=code; fi
fi

case "$editor" in
  code-server) user_directory="$HOME/.local/share/code-server/User" ;;
  code) user_directory="$HOME/.config/Code/User" ;;
  *) echo "Unknown editor '$editor': use code-server or code" >&2; exit 1 ;;
esac

mkdir -p "$user_directory"
for config_file in "$repo_directory"/User/*.json; do
  target_path="$user_directory/$(basename "$config_file")"
  if [ -f "$target_path" ]; then cp "$target_path" "$target_path.bak"; fi
  cp "$config_file" "$target_path"
  echo "Copied $(basename "$config_file") to $user_directory"
done

if [ -n "${SKIP_EXTENSIONS:-}" ]; then exit 0; fi

for vsix_file in "$repo_directory"/vsix/*.vsix; do
  "$editor" --install-extension "$vsix_file"
done
failed_extension_ids=()
while read -r extension_id; do
  extension_id="${extension_id%$'\r'}"
  if [ -z "$extension_id" ]; then continue; fi
  "$editor" --install-extension "$extension_id" || failed_extension_ids+=("$extension_id")
done < "$repo_directory/extensions.txt"

if [ ${#failed_extension_ids[@]} -gt 0 ]; then
  echo
  echo "Not available for $editor (skipped): ${failed_extension_ids[*]}"
fi
