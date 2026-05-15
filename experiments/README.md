# Kubernetes vs K3s OAI experiment notes

Folder ini menyimpan catatan eksperimen perbandingan vanilla Kubernetes/kubeadm di `awanbaru` dan K3s di `awanbagus`.

## Keputusan scope terbaru

Longhorn tetap dipakai sebagai komponen environment pendukung karena baseline `awanbaru` sudah berjalan dengan Longhorn dan PVC MySQL OAI memakai storage class `longhorn`.

Implikasi metodologi:

- Longhorn bukan variabel utama penelitian.
- Longhorn harus dipasang juga di `awanbagus` saat eksperimen K3s agar perbandingan resource tetap adil.
- Perbandingan utama tetap vanilla Kubernetes/kubeadm vs K3s untuk menjalankan OAI 5G Core dan RAN berbasis Helm.
- Resource yang dicatat mencakup overhead orchestrator, Flannel, Multus, Longhorn, dan OAI.

## Struktur catatan

| Path | Fungsi |
| --- | --- |
| `vanilla-kubeadm/` | Catatan baseline `awanbaru` |
| `k3s/` | Catatan pembanding `awanbagus` setelah K3s disiapkan |
| `results/` | Snapshot hasil validasi dan tabel perbandingan |

## Runbook terkait

Runbook operasional RAN single-node masih berada di root repo:

```text
RAN_SINGLE_NODE_RUNBOOK.md
```

Penempatan ini masih sesuai karena dokumen tersebut adalah runbook operasional umum untuk menjalankan dan memulihkan RAN single-node di `awanbaru`, bukan hanya tabel hasil eksperimen. Untuk laporan riset, hasil validasi dari runbook tersebut diringkas di `results/`.
