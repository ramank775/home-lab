#!/usr/bin/env bash
#
# Surgical fixups for `terraform plan -generate-config-out=generated.tf`
# bugs in the bpg/proxmox provider.
#
# The provider emits `units = 0` inside cpu { ... } blocks, but the schema
# rejects 0 (range is 1-500000 for LXC, 1-262144 for VM). Removing the line
# lets Terraform fall back to the schema default.
#
# Idempotent: safe to re-run after a fresh generate-config-out.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$(dirname "$SCRIPT_DIR")"
GEN_FILE="$MODULE_DIR/generated.tf"

if [[ ! -f "$GEN_FILE" ]]; then
  echo "generated.tf not found at $GEN_FILE" >&2
  exit 1
fi

BEFORE_LINES=$(wc -l <"$GEN_FILE")

# Delete any line that sets units to literal 0 (whitespace-flexible).
# Matches the failing pattern exactly; leaves units = <nonzero> alone.
sed -i '/^[[:space:]]*units[[:space:]]*=[[:space:]]*0[[:space:]]*$/d' "$GEN_FILE"

AFTER_LINES=$(wc -l <"$GEN_FILE")
REMOVED=$((BEFORE_LINES - AFTER_LINES))

echo "Removed $REMOVED 'units = 0' lines from generated.tf"
echo "Re-run plan to verify:"
echo "  terraform plan \\"
echo "    -var-file=/home/raman/git/home-lab/.lab/hypervisor/proxmox/values.tfvars"
