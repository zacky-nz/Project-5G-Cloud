# Environment baseline

Tanggal validasi: 2026-05-15 UTC

## Keputusan metodologi

Longhorn dicatat sebagai komponen aktif pada baseline `awanbaru`. Karena PVC `core-network/basic-mysql` memakai storage class `longhorn`, Longhorn tidak dihapus dari baseline.

Agar perbandingan tetap adil, VM K3s `awanbagus` nanti harus menjalankan komponen pendukung yang sama:

- K3s
- Flannel
- Multus
- Longhorn
- OAI 5G Core
- OAI CU/DU/NR-UE

## Baseline awanbaru

| Metrik | Nilai |
| --- | --- |
| Host | awanbaru |
| Node | awanbaru |
| Node IP | 172.20.0.11 |
| Orchestrator | Vanilla Kubernetes/kubeadm |
| Kubernetes version | v1.30.14 |
| Container runtime | containerd://1.7.28 |
| OS | Ubuntu 22.04.5 LTS |
| Primary CNI | Flannel |
| Secondary CNI | Multus |
| Storage component | Longhorn |
| Longhorn chart | longhorn-1.6.2 |
| Longhorn app version | v1.6.2 |
| Longhorn namespace | longhorn-system |
| Default StorageClass | longhorn |
| OAI MySQL PVC | core-network/basic-mysql, 8Gi, Bound, StorageClass longhorn |

## Status komponen aktif

| Komponen | Namespace | Status |
| --- | --- | --- |
| OAI 5G Core | core-network | Running |
| OAI CU/DU/NR-UE | ran-network | Running |
| Flannel | kube-flannel | Running |
| Multus | kube-system | Running |
| Longhorn | longhorn-system | Running |

## Catatan untuk awanbagus

Saat menyiapkan K3s di `awanbagus`, pasang Longhorn juga sebelum pengambilan data final. Versi yang disarankan untuk menyamai baseline:

```text
Longhorn chart: longhorn-1.6.2
Longhorn app version: v1.6.2
```

Jika versi yang sama tidak tersedia, catat versi aktual di tabel environment dan jelaskan sebagai keterbatasan eksperimen.
