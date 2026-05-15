# VM IP Resilience Runbook

This lab runs on a single Proxmox VM. If the VM is powered off or restarted and DHCP gives it a new IP address, services that use raw IP addresses can become unreachable.

## Recommended Solution

Use a DHCP reservation or static IP for the VM MAC address in Proxmox/router/DHCP server. This is the most stable option for Kubernetes because kubeadm, certificates, kubelet node identity, CNI, and ingress access all prefer a stable node address.

Recommended target:

```text
VM hostname: awanbaru
Stable lab IP: 172.20.0.11
```

## Practical Fallback

When a static IP is not possible, use hostnames instead of typing VM IPs directly for lab infrastructure endpoints.

The repo provides:

```bash
scripts/vm-ip-doctor.sh
```

Dry-run:

```bash
scripts/vm-ip-doctor.sh
```

Apply current VM IP to local hostnames:

```bash
sudo scripts/vm-ip-doctor.sh --apply-hosts
```

If auto-detection picks the wrong interface:

```bash
sudo VM_IP=172.20.0.11 scripts/vm-ip-doctor.sh --apply-hosts
```

The script updates `/etc/hosts` for:

```text
jenkins.orca.edu
longhorn.orca.edu
prometheus.orca.edu
grafana.orca.edu
pma.orca.edu
```

## What Was Changed

The active branch is now 5G/infrastructure focused, so the legacy dashboard application is not part of this cleanup. The host remapping helper only keeps infrastructure endpoints reachable after the VM receives a different DHCP address.

## What This Does Not Fix

If Kubernetes itself was initialized with an old fixed API server IP and the VM IP changes, `/etc/hosts` is not enough. The safer fix is still to reserve a stable DHCP/static IP for the VM.

Symptoms of deeper cluster IP drift:

```bash
kubectl get nodes
kubectl get pods -A
```

If those commands fail after an IP change, fix the VM IP reservation first, then restart the VM or renew kubeadm certificates only if required.
