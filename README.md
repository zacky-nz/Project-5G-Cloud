# Project-5G-Cloud

Cloud-native 5G network simulation and deployment project using Kubernetes, OpenAirInterface (OAI), Multus CNI, Helm, Argo CD, Longhorn, Prometheus, and Grafana.

This project is part of the research:

**5G Network Simulation System Based on Centralized Dashboard in Cloud Native Environment**

The active repository scope is now the 5G network and supporting infrastructure. Legacy dashboard/application sources have been removed from this branch so a new VM clone stays focused on the OAI core, RAN, monitoring, storage, and GitOps pieces.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Latest Verified Progress](#latest-verified-progress)
- [Team and Roles](#team-and-roles)
- [System Architecture](#system-architecture)
- [Repository Structure](#repository-structure)
- [Technology Stack](#technology-stack)
- [Current Infrastructure](#current-infrastructure)
- [VM IP Resilience](#vm-ip-resilience)
- [Namespace Layout](#namespace-layout)
- [Network and Interface Plan](#network-and-interface-plan)
- [Important Fixes Applied](#important-fixes-applied)
- [Deployment Notes](#deployment-notes)
- [Verification Runbook](#verification-runbook)
- [Control Plane Verification](#control-plane-verification)
- [Dataplane Testing](#dataplane-testing)
- [UPF Dataplane Debugging](#upf-dataplane-debugging)
- [Common Issues and Solutions](#common-issues-and-solutions)
- [Known Current State](#known-current-state)
- [GitOps and Argo CD Notes](#gitops-and-argo-cd-notes)
- [Research Testing Results](#research-testing-results)

---

## Project Overview

Project-5G-Cloud contains OAI CNF manifests, Helm charts, and Kubernetes configuration used to deploy a simulated 5G network in a cloud-native environment.

The system includes:

- 5G Core Network based on OpenAirInterface
- RAN simulation using OAI CU, DU, and NR-UE
- RF simulator mode for UE-to-DU connectivity
- Multus CNI for secondary 5G network interfaces
- Flannel as the primary Kubernetes CNI
- Longhorn for storage
- Argo CD for GitOps

---

## Latest Verified Progress

The current stable demo scope is **SINGLE / level1 / single-node lab**.

Verified result:

```text
Core Network: Running
RAN CU/DU/NR-UE: Running
UE tunnel: oaitun_ue1 = 12.1.1.100/24
Dataplane test: UE -> UPF gateway ping success
Packet loss: 0%
```

Latest successful dataplane proof:

```text
PING 12.1.1.1 (12.1.1.1) from 12.1.1.100 oaitun_ue1
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max/mdev = 6.595/7.409/8.256/0.683 ms
```

Balanced resource optimization has also been applied to Prometheus, Grafana, cAdvisor, CU, DU, and NR-UE so the lab remains lighter for a single VM.

---

## Team and Roles

| Name | Student ID | Role |
| --- | --- | --- |
| Ari Erginta Ginting | 1101204178 | Infrastructure |
| Ima Dewi Arofani | 1101204375 | Archived dashboard UI |
| Bagus Dwi Prasetyo | 1101204109 | Archived dashboard API |
| M. Rafli Hadiana | 1101202426 | 5G System |

---

## System Architecture

The system is deployed on Kubernetes using a cloud-native architecture.

Main components:

```text
Operator
      |
      v
kubectl / Helm / Argo CD
      |
      v
+-----------------------------+
| Kubernetes Cluster           |
|                              |
|  core-network namespace      |
|  - AMF                       |
|  - SMF                       |
|  - UPF                       |
|  - NRF                       |
|  - AUSF                      |
|  - UDM                       |
|  - UDR                       |
|  - MySQL                     |
|                              |
|  ran-network namespace       |
|  - OAI CU                    |
|  - OAI DU                    |
|  - OAI NR-UE                 |
|                              |
|  kube-system                 |
|  - Flannel                   |
|  - Multus                    |
|                              |
|  longhorn-system             |
|  - Longhorn storage          |
+-----------------------------+
```

---

## Repository Structure

```text
Project-5G-Cloud/
├── AN-ORCA-CNF/               # OAI CNF Helm charts and manifests
│   ├── oai-5g-core/           # 5G Core Helm charts
│   ├── user_n/                # RAN, CU, DU, and UE Helm charts
│   └── multus-daemonset.yml   # Multus CNI manifest
├── AN-ORCA-MANIFESTS/         # Infrastructure manifests
├── docs/                      # Operational runbooks
├── scripts/                   # Operational helper scripts
└── README.md
```

Generated Helm render files such as `rendered-*.yaml` are intentionally ignored and should be regenerated locally when needed.

---

## Technology Stack

### Infrastructure

- Kubernetes vanilla / kubeadm
- Flannel CNI as the primary CNI
- Multus CNI as the secondary CNI
- Longhorn for storage management
- Argo CD for GitOps
- Jenkins for automation flow
- Prometheus and Grafana for monitoring

### 5G Network

- OpenAirInterface 5G Core
- OpenAirInterface CU / DU / NR-UE
- Helm charts for CNF deployment
- RF simulator for DU and UE connection
- Secondary interfaces for N2, N3, N4, and F1

## Current Infrastructure

Current runtime environment:

| Item | Value |
| --- | --- |
| Node | `tr-an` |
| Host / VM | `awanbaru` |
| Current Node IP | `172.20.0.11` |
| IPv6 | `fe80::be24:11ff:fef3:2de0` |
| CPU | 16 vCPU |
| RAM | 23 GiB |
| Boot Disk | 100 GiB |
| HA State | none |
| Status | running |

Notes:

- The initial design used 3 nodes: 1 master and 2 worker nodes.
- The current runtime environment uses 1 active node.
- Do not mix the initial design data with the current troubleshooting data.
- If Proxmox gives the VM a new IP after restart, prefer DHCP reservation/static IP. If that is not possible, use `scripts/vm-ip-doctor.sh` to remap lab hostnames.

---

## VM IP Resilience

The lab should avoid hard-coding raw VM IPs in daily operation. Use hostnames for infrastructure endpoints such as:

```text
grafana.orca.edu
longhorn.orca.edu
prometheus.orca.edu
jenkins.orca.edu
pma.orca.edu
```

Recommended permanent fix:

```text
Reserve the VM MAC address in Proxmox/router/DHCP so awanbaru keeps the same IP.
```

Fallback when DHCP still changes the VM IP:

```bash
scripts/vm-ip-doctor.sh
sudo scripts/vm-ip-doctor.sh --apply-hosts
```

The script detects the current VM IP and updates `/etc/hosts` for the lab hostnames. More detail is documented in:

```text
docs/VM_IP_RESILIENCE.md
```

---

## Namespace Layout

Recommended namespace separation:

| Namespace | Purpose |
| --- | --- |
| `core-network` | 5G Core Network components |
| `ran-network` | OAI CU, DU, and NR-UE |
| `kube-system` | Kubernetes system components, Flannel, and Multus |
| `longhorn-system` | Longhorn storage |
| `argocd` | Argo CD |
| `monitoring` | Prometheus and monitoring components |

Expected active components:

```text
core-network:
- basic-mysql
- oai-amf
- oai-ausf
- oai-nrf
- oai-smf
- oai-udm
- oai-udr
- oai-upf

ran-network:
- oai-cu-level1
- oai-du-level1
- oai-nr-ue-level1
```

Old or duplicate RAN components in `core-network` should be removed or scaled down.

---

## Network and Interface Plan

### Core Network Interfaces

| Component | Interface | IP Address |
| --- | --- | --- |
| AMF | `n2` | `172.20.0.200/16` |
| UPF | `n3` | `172.20.0.201/16` |
| UPF | `n4` | `172.20.0.202/16` |
| SMF | `n4` | `172.20.0.203/16` |

### RAN Interfaces

| Component | Interface | IP Address |
| --- | --- | --- |
| CU | `n2` | `172.20.0.210/16` |
| CU | `n3` | `172.20.0.211/16` |
| CU | `f1` | `172.20.0.212/16` |
| DU | `f1` | `172.20.0.213/16` |
| UE | RF simulator | `172.20.1.214/24` |

### UE Tunnel

Expected UE tunnel after successful PDU session:

```text
oaitun_ue1: 12.1.1.100/24
UPF tun0:   12.1.1.1/24
```

---

## Important Fixes Applied

The following fixes were applied during troubleshooting:

| Area | Fix |
| --- | --- |
| Multus CNI | Fixed Multus daemonset and CNI path for vanilla Kubernetes |
| CNI path | Updated from K3s path to `/etc/cni/net.d` and `/opt/cni/bin` |
| CU configuration | Aligned `n2`, `n3`, and `f1` interface names with Multus annotations |
| DU configuration | Aligned DU F1 address and CU host configuration |
| RFSIM | Configured DU as RF simulator server and UE to connect to `oai-du-rfsim` service |
| AMF and UPF | Recreated pods so Multus interfaces `n2`, `n3`, and `n4` were attached properly |
| OAI image | Used compatible RAN image version to avoid F1 decode errors |
| Routing | Updated CU / DU route and interface configuration |
| Namespace cleanup | Active RAN path moved to `ran-network`; old duplicate RAN in `core-network` should be disabled |
| Resource optimization | Applied Balanced resource limits to monitoring and RAN components |
| VM IP resilience | Added host remapping helper for lab infrastructure endpoints after VM IP changes |
| Repository cleanup | Removed generated `rendered-*.yaml` files and ignored future render output |
| Operation script | Updated `AN-ORCA-CNF/operation.sh` defaults to use `core-network` and `ran-network` namespaces |
| DiskPressure recovery | Freed local disk, removed evicted pods, and restarted CNF in the correct UPF -> SMF -> AMF -> CU -> DU -> UE order |

---

## Deployment Notes

### Install Core Network

```bash
helm install basic ./AN-ORCA-CNF/oai-5g-core/oai-5g-basic/ -n core-network
```

### Install RAN Single UE Scenario

```bash
helm install oai-cu-level1 ./AN-ORCA-CNF/user_n/oai-e2e/oai-cu/ -n ran-network
helm install oai-du-level1 ./AN-ORCA-CNF/user_n/oai-e2e/oai-du/ -n ran-network
helm install oai-nr-ue-level1 ./AN-ORCA-CNF/user_n/oai-e2e/oai-nr-ue/ -n ran-network
```

### Upgrade Core Network

```bash
helm upgrade basic ./AN-ORCA-CNF/oai-5g-core/oai-5g-basic/ -n core-network
```

### Upgrade RAN

```bash
helm upgrade oai-cu-level1 ./AN-ORCA-CNF/user_n/oai-e2e/oai-cu/ -n ran-network
helm upgrade oai-du-level1 ./AN-ORCA-CNF/user_n/oai-e2e/oai-du/ -n ran-network
helm upgrade oai-nr-ue-level1 ./AN-ORCA-CNF/user_n/oai-e2e/oai-nr-ue/ -n ran-network
```

---

## Verification Runbook

### 1. Check Pods

```bash
kubectl get pods -A
kubectl get pods -n core-network
kubectl get pods -n ran-network
```

Expected:

```text
core-network:
AMF, SMF, UPF, NRF, AUSF, UDM, UDR, MySQL = Running

ran-network:
CU, DU, NR-UE = Running
```

### 2. Check Multus Network Attachment Definitions

```bash
kubectl get network-attachment-definitions -A
```

### 3. Check Multus Logs

```bash
kubectl logs -n kube-system -l app=multus -c kube-multus --tail=50
```

### 4. Check Network Status Annotation

```bash
kubectl get pod -n core-network -l app.kubernetes.io/name=oai-amf \
  -o jsonpath='{.items[0].metadata.annotations.k8s\.v1\.cni\.cncf\.io/networks-status}'

kubectl get pod -n core-network -l app.kubernetes.io/name=oai-upf \
  -o jsonpath='{.items[0].metadata.annotations.k8s\.v1\.cni\.cncf\.io/networks-status}'
```

### 5. Check Required Interfaces

```bash
kubectl exec -n core-network deploy/oai-amf -- ip addr show n2
kubectl exec -n core-network deploy/oai-upf -- ip addr show n3
kubectl exec -n core-network deploy/oai-upf -- ip addr show n4

kubectl exec -n ran-network deploy/oai-cu-level1 -- ip addr show n2
kubectl exec -n ran-network deploy/oai-cu-level1 -- ip addr show n3
kubectl exec -n ran-network deploy/oai-cu-level1 -- ip addr show f1
kubectl exec -n ran-network deploy/oai-du-level1 -- ip addr show f1
```

---

## Control Plane Verification

### DU to CU F1 Setup

```bash
kubectl logs -n ran-network deploy/oai-du-level1 | grep -Ei "f1|f1ap|setup|connected"
kubectl logs -n ran-network deploy/oai-cu-level1 | grep -Ei "f1|f1ap|du|setup|connected"
```

Expected indicators:

```text
F1 Setup Request
F1 Setup Response
DU connected
```

### CU to AMF NG Setup

```bash
kubectl logs -n ran-network deploy/oai-cu-level1 | grep -Ei "ngap|amf|sctp|setup|connected"
kubectl logs -n core-network deploy/oai-amf | grep -Ei "ngap|gnb|sctp|setup|registration"
```

Expected indicators:

```text
NG Setup Request
NG Setup Response
gNB connected
```

### UE Registration

```bash
kubectl logs -n ran-network deploy/oai-nr-ue-level1 | grep -Ei "registration|registered|pdu|session|nas|rrc|connected"
kubectl logs -n core-network deploy/oai-amf | grep -Ei "ue|registration|5gmm|authentication|security"
kubectl logs -n core-network deploy/oai-smf | grep -Ei "pdu|session|active|upf|n4"
```

Expected indicators:

```text
RRC_CONNECTED
5GMM-REGISTERED
PDU session ACTIVE
```

---

## Dataplane Testing

### 1. Check UE Tunnel

```bash
kubectl exec -n ran-network -it deploy/oai-nr-ue-level1 -- bash
```

Inside the UE pod:

```bash
ip addr show oaitun_ue1
ip route
```

Expected:

```text
oaitun_ue1: 12.1.1.100/24
```

### 2. Ping UPF Tunnel Gateway

```bash
ping -I oaitun_ue1 -c 4 12.1.1.1
```

Expected:

```text
4 packets transmitted, 4 received
```

If this fails, troubleshoot N3 / GTP-U / UPF PDR-FAR first.

### 3. Ping Internet

```bash
ip route replace 8.8.8.8 dev oaitun_ue1
ping -c 4 8.8.8.8
```

### 4. Test HTTP

```bash
curl --interface oaitun_ue1 http://example.com
```

---

## UPF Dataplane Debugging

If UE receives IP but cannot ping `12.1.1.1`, run tcpdump from a debug container because the UPF image may not include `tcpdump`.

```bash
kubectl debug -n core-network -it pod/<upf-pod-name> \
  --image=nicolaka/netshoot \
  --target=upf \
  -- bash
```

Inside debug container:

```bash
tcpdump -ni any "icmp or udp port 2152"
```

Then, from the UE pod:

```bash
ping -I oaitun_ue1 -c 4 12.1.1.1
```

Interpretation:

| tcpdump Result | Meaning |
| --- | --- |
| No ICMP or UDP 2152 | UE traffic does not reach UPF; check CU N3 and GTP-U |
| UDP 2152 appears but no ICMP on `tun0` | UPF receives GTP-U but PDR/FAR/TEID may not match |
| ICMP appears on `tun0` but no reply | Check UPF `tun0`, iptables, and forwarding |
| ICMP request and reply appear | Check return path to UE |

---

## SNAT and Forwarding

Check UPF forwarding:

```bash
kubectl exec -n core-network -it deploy/oai-upf -- bash
sysctl net.ipv4.ip_forward
iptables -t nat -S
iptables -S FORWARD
```

Expected:

```text
net.ipv4.ip_forward = 1
POSTROUTING rule for 12.1.1.0/24
```

Example UPF NAT rule:

```bash
iptables -t nat -A POSTROUTING -s 12.1.1.0/24 -o eth0 -j MASQUERADE
```

If traffic reaches the host but cannot go out to the internet, check host forwarding and NAT:

```bash
sudo sysctl net.ipv4.ip_forward
ip route | grep default
sudo iptables -t nat -S | grep -E "MASQUERADE|10.244|12.1.1"
```

---

## Common Issues and Solutions

| Issue | Symptom | Root Cause | Solution |
| --- | --- | --- | --- |
| UE stuck `REG-INITIATED` | AMF shows `REG-INITIATED` | IMSI / Key / OPc mismatch | Verify UE credentials match the database |
| `SUBSCRIPTION_DENIED` | AMF receives 403 from SMF | S-NSSAI or DNN not authorized | Align `sst`, `sd`, and `dnn` in UE, DB, and core config |
| `oaitun_ue1` is down | No UE IP assigned | PDU session not established | Check AMF, SMF, and UPF logs |
| Ping timeout | UE has IP but no connectivity | UPF routing, SNAT, N6, or N3 issue | Check N3 GTP-U, UPF PDR/FAR, and SNAT |
| `CrashLoopBackOff` | Pod keeps restarting | Multus or interface error | Verify `nodeSelector`, `hostInterface`, and CNI path |
| `AddressSanitizer` error | Error appears in RAN logs | Buggy or incompatible image version | Use compatible OAI RAN image |
| CU not visible in AMF | gNB list is empty | N2 SCTP failure | Verify CU `n2` IP can reach AMF SCTP port |
| `Device n2 does not exist` | AMF/CU fails to start | Multus did not attach interface | Check NAD, Multus daemonset, and CNI binary path |
| F1 decode error | DU cannot connect to CU | CU/DU image or config mismatch | Align CU/DU image versions and F1 config |
| UE cannot connect to DU | RF simulator connection fails | RFSIM server/client mismatch | Run DU as RFSIM server and UE as client to `oai-du-rfsim` |
| Node `DiskPressure` | New pods become `Evicted` immediately | Root disk or container image pressure | Free disk, clean failed pods, wait for `DiskPressure=False`, then restart CNF |
| `No UPF available` in SMF | UE registers but `oaitun_ue1` stays down | SMF-UPF PFCP/N4 association stale | Restart `oai-upf`, then `oai-smf`, then `oai-amf`, then restart CU/DU/UE |

Recommended CNF recovery order after VM restart, DiskPressure, or stale NRF/PFCP state:

```bash
kubectl -n core-network rollout restart deploy/oai-upf
kubectl -n core-network rollout status deploy/oai-upf

kubectl -n core-network rollout restart deploy/oai-smf deploy/oai-amf
kubectl -n core-network rollout status deploy/oai-smf
kubectl -n core-network rollout status deploy/oai-amf

kubectl -n ran-network rollout restart deploy/oai-cu-level1 deploy/oai-du-level1 deploy/oai-nr-ue-level1
kubectl -n ran-network rollout status deploy/oai-cu-level1
kubectl -n ran-network rollout status deploy/oai-du-level1
kubectl -n ran-network rollout status deploy/oai-nr-ue-level1
```

---

## Known Current State

The latest verified status:

```text
DU-CU F1 setup: success
CU-AMF NG setup: success
UE RF simulator connection to DU: success
UE RRC state: RRC_CONNECTED
AMF UE state: 5GMM-REGISTERED
SMF PDU session: ACTIVE
UE tunnel: oaitun_ue1 with IP 12.1.1.100/24
Dataplane: ping from UE tunnel to UPF gateway 12.1.1.1 succeeds
```

Current infra notes:

```text
Argo CD, Longhorn, Prometheus, Grafana, and cAdvisor are running.
Jenkins resources exist, but Jenkins deployment is currently scaled to 0.
Longhorn volumes may show degraded on a single-node lab; this is expected and should not be presented as HA storage.
```

---

## GitOps and Argo CD Notes

This project uses Argo CD for GitOps.

Important notes:

- Do not enable Argo CD self-heal or sync before all working changes are committed to Git.
- Manual cluster changes may be reverted by Argo CD if they are not reflected in the Git source.
- Argo CD applications may show `OutOfSync` while manual debugging changes exist.
- Commit working configuration first, then run Argo CD sync.

Check Argo CD applications:

```bash
kubectl get applications -n argocd
kubectl get applications -n argocd -o yaml | grep -Ei "repoURL|targetRevision|path|syncPolicy" -A5 -B3
```

Recommended flow:

```bash
git status
git add .
git commit -m "Fix OAI 5G RAN and core network configuration"
git push origin <branch-name>
```

After confirming the pushed branch is the same branch used by the target Argo CD application:

```bash
argocd app diff <app-name>
argocd app sync <app-name>
```

## Guardrails

- Avoid editing live host files unless required for emergency debugging.
- Prefer Git-based changes for Argo CD-managed resources.
- Avoid deleting pods or patching resources manually unless the change is understood.
- Before restarting multiple pods, check memory, storage, and Longhorn status.
- Keep `core-network` for 5G core components only.
- Keep active RAN components in `ran-network`.
- Remove or scale down duplicate old RAN deployments in `core-network`.

---

## Research Testing Results

### Resource Per User

| Resource | RPU | 5% Tolerance | Rounded |
| --- | --- | --- | --- |
| CPU | 2781 mCPU | 2920 mCPU | 3000 mCPU |
| RAM | 1965 MiB | 2063 MiB | 2100 MiB |

Formula:

```text
Total CPU = total user x RPU CPU
Total RAM = total user x RPU RAM
Total user = (total resource - idle resource) / RPU
```

### Historical Application Testing

The dashboard/application results below are historical research records. The active branch no longer includes the application source.

| Test | Amount | Result |
| --- | --- | --- |
| API Testing | 38 APIs, 30 tests each | 100% success |
| E2E Testing | 38 functions, 10 tests each | 100% success |
| UAT Functional | 38 features | 100% success |
| UAT SUS Score | 30 respondents | Improved from 65.42 to 77.1 |

Recorded maximum E2E connection capacity:

```text
10 users stable
Drop occurred at user 11
```

---

## Maintainers

This repository is maintained by the Project-5G-Cloud research team.

For deployment, debugging, or GitOps changes, always verify the current Kubernetes state before applying modifications.
