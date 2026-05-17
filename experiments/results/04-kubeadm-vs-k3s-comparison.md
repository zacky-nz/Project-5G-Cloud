# Vanilla kubeadm vs K3s comparison

Tanggal rangkuman: 2026-05-17 UTC

## Scope

Perbandingan ini memakai:

- Vanilla Kubernetes/kubeadm di `awanbaru`: `02-vanilla-deployment-result.md`
- K3s di `awanbagus`: `03-k3s-deployment-result.md`

Kedua environment menjalankan Flannel, Multus, Longhorn, OAI 5G Core, dan OAI RAN berbasis Helm.

## Ringkasan hasil

| Item | Vanilla kubeadm: awanbaru | K3s: awanbagus |
| --- | --- | --- |
| Node IP | 172.20.0.11 | 172.20.0.25 |
| Kubernetes | v1.30.14 | v1.30.14+k3s2 |
| Runtime | containerd://1.7.28 | containerd://1.7.27-k3s1 |
| Storage | Longhorn v1.6.2 | Longhorn v1.6.2 |
| Core OAI | Running | Running |
| RAN OAI | Running | Running |
| UE registered | OK | OK |
| PDU/dataplane | OK | OK |
| Ping UE to UPF tunnel | OK, 4/4 received | OK, 4/4 received |

## Resource snapshot

| Metrik | Vanilla kubeadm: awanbaru | K3s: awanbagus |
| --- | --- | --- |
| RAM total | 22 GiB | 22 GiB |
| RAM used after OAI | 5.7 GiB | 5.2 GiB |
| RAM available | 16 GiB | 16 GiB |
| Disk root size | 97 GiB | 97 GiB |
| Disk root used | 62 GiB | 12 GiB |
| Disk root available | 36 GiB | 86 GiB |
| Disk root usage | 64% | 12% |
| Pod count all namespaces | 37 | 32 |
| Container count | 39 | 34 |
| Image count | 41 | 26 |

## Interpretasi awal

Kedua cluster sudah valid untuk workload OAI yang sama: core dan RAN berjalan, interface Multus muncul, UE registered, tunnel UE aktif, dan ping dataplane berhasil.

Snapshot saat ini menunjukkan K3s memakai RAM sedikit lebih rendah dan jumlah pod/container lebih sedikit. Namun disk usage dan image count belum sepenuhnya apple-to-apple karena isi filesystem/image cache tiap VM bisa berbeda sebelum eksperimen.

## Catatan metodologi

- Longhorn dipertahankan di kedua sisi karena baseline vanilla sudah memakai Longhorn untuk PVC MySQL OAI.
- Snapshot resource diambil setelah workload berjalan, bukan pada kondisi idle cluster kosong.
- Untuk angka final laporan, ambil ulang snapshot resource pada waktu yang berdekatan setelah kedua cluster baru direstart atau setelah kondisi cache/image disamakan.
