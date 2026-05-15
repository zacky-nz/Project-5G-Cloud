#!/usr/bin/env bash
set -euo pipefail

HOSTS=(
  jenkins.orca.edu
  longhorn.orca.edu
  prometheus.orca.edu
  grafana.orca.edu
  pma.orca.edu
)

BEGIN_MARKER="# BEGIN PROJECT-5G-CLOUD VM HOSTS"
END_MARKER="# END PROJECT-5G-CLOUD VM HOSTS"
APPLY_HOSTS=0
SHOW_HELP=0

for arg in "$@"; do
  case "$arg" in
    --apply-hosts)
      APPLY_HOSTS=1
      ;;
    -h|--help)
      SHOW_HELP=1
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

if [[ "$SHOW_HELP" -eq 1 ]]; then
  cat <<'EOF'
Usage:
  scripts/vm-ip-doctor.sh
  scripts/vm-ip-doctor.sh --apply-hosts

The script detects the current VM IP and can update /etc/hosts so lab
infrastructure hostnames such as grafana.orca.edu and longhorn.orca.edu
keep working after the Proxmox VM receives a different DHCP address.
EOF
  exit 0
fi

detect_vm_ip() {
  if [[ -n "${VM_IP:-}" ]]; then
    echo "$VM_IP"
    return
  fi

  ip -4 route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i=="src") {print $(i+1); exit}}'
}

detect_node_ip() {
  if ! command -v kubectl >/dev/null 2>&1; then
    return
  fi

  kubectl get node -o jsonpath='{range .items[0].status.addresses[?(@.type=="InternalIP")]}{.address}{end}' 2>/dev/null || true
}

VM_IP_DETECTED="$(detect_vm_ip)"
NODE_IP_DETECTED="$(detect_node_ip)"

if [[ -z "$VM_IP_DETECTED" ]]; then
  echo "Could not detect VM IP. Set VM_IP manually, for example:" >&2
  echo "  VM_IP=172.20.0.11 scripts/vm-ip-doctor.sh --apply-hosts" >&2
  exit 1
fi

echo "Detected VM IP: ${VM_IP_DETECTED}"
if [[ -n "$NODE_IP_DETECTED" ]]; then
  echo "Detected Kubernetes node IP: ${NODE_IP_DETECTED}"
  if [[ "$NODE_IP_DETECTED" != "$VM_IP_DETECTED" ]]; then
    echo "WARNING: VM IP and Kubernetes node InternalIP are different."
    echo "If the API server or CNI fails after reboot, prefer a DHCP reservation/static IP for the VM."
  fi
else
  echo "Kubernetes node IP: not available"
fi

echo
echo "Hostnames managed by this script:"
printf '  %s\n' "${HOSTS[@]}"

HOSTS_LINE="${VM_IP_DETECTED} ${HOSTS[*]}"

if [[ "$APPLY_HOSTS" -eq 0 ]]; then
  echo
  echo "Dry run only. To update /etc/hosts, run:"
  echo "  sudo VM_IP=${VM_IP_DETECTED} $0 --apply-hosts"
  exit 0
fi

TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

if [[ -f /etc/hosts ]]; then
  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
    $0 == begin {skip=1; next}
    $0 == end {skip=0; next}
    skip != 1 {print}
  ' /etc/hosts > "$TMP_FILE"
fi

{
  echo "$BEGIN_MARKER"
  echo "$HOSTS_LINE"
  echo "$END_MARKER"
} >> "$TMP_FILE"

install -m 0644 "$TMP_FILE" /etc/hosts
echo "/etc/hosts updated for VM IP ${VM_IP_DETECTED}"
