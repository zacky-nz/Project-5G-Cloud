# Project-5G-Cloud

Adaptive Networking research with the aim of minimizing resource usage.

## Ringkasan Proyek

Project ini berisi komponen ORCA (Open RAN Configuration App) untuk simulasi dan deployment 5G berbasis cloud native. Sistem memakai Kubernetes sebagai container orchestrator, Cloud-native Network Function (CNF), OpenAirInterface (OAI), serta aplikasi frontend dan backend untuk otomasi deployment.

Nama penelitian: 5G Network Simulation System Based on Centralized Dashboard in Cloud Native Environment.

## Tim dan Role

| Nama | NIM | Role |
| --- | --- | --- |
| Ari Erginta Ginting | 1101204178 | Infrastructure |
| Ima Dewi Arofani | 1101204375 | Frontend |
| Bagus Dwi Prasetyo | 1101204109 | Backend |
| M. Rafli Hadiana | 1101202426 | 5G System |

## Status Infrastruktur Saat Ini

Data berikut disesuaikan dengan screenshot node `awanbaru` yang diberikan.

| Item | Nilai |
| --- | --- |
| Node | `tr-an` |
| Host/VM | `awanbaru` |
| IP node | `172.20.0.11` |
| IPv6 | `fe80::be24:11ff:fef3:2de0` |
| CPU | 16 vCPU |
| CPU usage | 2.35% dari 16 CPU |
| RAM | 23.00 GiB total, 10.10 GiB terpakai |
| RAM usage | 43.92% |
| Boot disk | 100.00 GiB |
| HA state | none |
| Status | running |

Catatan:

- Screenshot slide sidang menampilkan desain awal 3 node: 1 master dan 2 worker.
- Kondisi runtime saat ini terlihat sebagai 1 node aktif dengan 16 vCPU, 23 GiB RAM, dan 100 GiB boot disk.
- Jangan mencampur data desain awal dengan data runtime saat troubleshooting.

## Struktur Repository

```text
Project-5G-Cloud/
|-- AN-OPEN-NETRA-FE/      # Frontend ORCA
|-- AN-ORCA-CNF/           # Helm chart dan manifest CNF/OAI
|   |-- oai-5g-core/       # 5G core charts
|   |-- user_n/            # RAN, CU, DU, dan UE charts
|   `-- multus-daemonset.yml
|-- AN-ORCA-MANIFESTS/     # Manifest aplikasi dan infrastruktur
`-- README.md
```

## Stack Utama

Infrastructure:

- Kubernetes vanilla/kubeadm, bukan K3s
- Flannel sebagai primary CNI
- Multus CNI sebagai secondary CNI untuk interface 5G
- Longhorn untuk storage management
- Argo CD untuk GitOps
- Jenkins untuk automation flow
- Prometheus dan Grafana untuk monitoring

5G Software:

- OpenAirInterface (OAI)
- Helm chart untuk 5G core, CU, DU, dan UE
- Namespace yang sering dipakai: `core-network` dan `ran-network`

ORCA Application:

- Frontend: React
- Backend: Django, Django REST Framework, Django Channels
- Database dan broker: PostgreSQL dan Redis
- Integrasi deployment: Helm, Kubernetes API, dan Python subprocess

## Perbaikan yang Dilakukan di Repo

Perubahan ini hanya menyentuh file di dalam `~/Project-5G-Cloud`.

| File | Perubahan |
| --- | --- |
| `AN-ORCA-CNF/multus-daemonset.yml` | Path K3s diganti ke path vanilla Kubernetes: `/etc/cni/net.d` dan `/opt/cni/bin`. |
| `AN-ORCA-CNF/oai-5g-core/oai-5g-basic/values.yaml` | IP Multus AMF/UPF/SMF diselaraskan ke subnet runtime `172.20.0.0/16`. |
| `AN-ORCA-CNF/user_n/oai-e2e/oai-cu/values.yaml` | Nama interface CU diselaraskan dengan annotation Multus: `n2`, `n3`, dan `f1`. |
| `AN-ORCA-CNF/user_n/oai-e2e/oai-cu/templates/` | Alamat F1 dan `DU_HOST` dibuat mengikuti values, bukan hardcode `172.20.1.x`. |
| `AN-ORCA-CNF/user_n/oai-e2e/oai-du/` | `cuHost`, alamat F1 DU, service account, dan startup command diselaraskan dengan IP CU/DU di values. |
| `README.md` | Catatan lama dirapikan, duplikasi dihapus, dan data resource disesuaikan dengan screenshot terbaru. |

## Guardrail Perubahan

- Tidak ada file di luar `~/Project-5G-Cloud` yang diedit.
- Perubahan live seperti `/etc/cni/net.d/00-multus.conf`, `/opt/cni/bin`, restart pod, atau patch resource Kubernetes membutuhkan persetujuan eksplisit terlebih dahulu.
- Perintah `kubectl delete pod`, `sudo tee`, `sudo ip link`, dan edit file host di luar repo tidak dijalankan dalam perbaikan ini.

## Root Cause yang Sedang Ditangani

Masalah utama yang tercatat adalah pod OAI gagal menemukan interface tambahan seperti `n2` dan `n3`.

Gejala yang pernah muncul:

```text
Failed to probe n2 inet addr: error No such device
Validation of AMF not successful: Error in reading network interface n2
Failed to probe n3 inet addr: error No such device
```

Kemungkinan penyebab:

- Multus daemonset sebelumnya memasang `multus-shim` ke path K3s.
- Cluster yang digunakan adalah vanilla Kubernetes, sehingga kubelet membaca CNI dari `/etc/cni/net.d` dan binary CNI dari `/opt/cni/bin`.
- Jika `multus-shim` tidak ada di `/opt/cni/bin`, kubelet tidak dapat menjalankan Multus dengan benar.
- Jika config CNI tidak ada di `/etc/cni/net.d`, kubelet tidak membaca konfigurasi Multus yang benar.

## Konfigurasi Multus yang Diharapkan

Untuk thick Multus, konfigurasi host yang biasanya diperlukan:

```json
{
  "cniVersion": "0.3.1",
  "name": "multus-cni-network",
  "type": "multus-shim",
  "socketDir": "/run/multus/"
}
```

Lokasi host yang relevan:

```text
/etc/cni/net.d/00-multus.conf
/etc/cni/net.d/10-flannel.conflist
/etc/cni/net.d/multus.d/multus.kubeconfig
/opt/cni/bin/multus-shim
/run/multus/multus.sock
```

## IP dan Interface yang Diselaraskan

Core network:

| Komponen | Interface | IP |
| --- | --- | --- |
| AMF | `n2` | `172.20.0.200/16` |
| UPF | `n3` | `172.20.0.201/16` |
| UPF | `n4` | `172.20.0.202/16` |
| SMF | `n4` | `172.20.0.203/16` |

RAN/CU:

| Komponen | Interface | IP |
| --- | --- | --- |
| CU | `n2` | `172.20.0.210/16` |
| CU | `n3` | `172.20.0.211/16` |
| CU | `f1` | `172.20.0.212/16` |
| DU | `f1` | `172.20.0.213/16` |

## Runbook Verifikasi

Jalankan perintah berikut setelah perubahan repo di-apply ke cluster.

```bash
kubectl get pods --all-namespaces
kubectl get network-attachment-definitions --all-namespaces
kubectl logs -n kube-system -l app=multus -c kube-multus --tail=50
kubectl get pod -n core-network -l app.kubernetes.io/name=oai-amf -o jsonpath='{.items[0].metadata.annotations.k8s\.v1\.cni\.cncf\.io/networks-status}'
kubectl get pod -n core-network -l app.kubernetes.io/name=oai-upf -o jsonpath='{.items[0].metadata.annotations.k8s\.v1\.cni\.cncf\.io/networks-status}'
```

Interface yang perlu terlihat di pod:

```bash
kubectl exec -n core-network deploy/oai-amf -- ip addr show n2
kubectl exec -n core-network deploy/oai-upf -- ip addr show n3
kubectl exec -n core-network deploy/oai-upf -- ip addr show n4
kubectl exec -n ran-network deploy/oai-cu-level1 -- ip addr show n2
kubectl exec -n ran-network deploy/oai-cu-level1 -- ip addr show n3
kubectl exec -n ran-network deploy/oai-cu-level1 -- ip addr show f1
```

Jika interface sudah muncul, restart AMF, UPF, lalu CU secara berurutan.

```bash
kubectl delete pod -n core-network -l app.kubernetes.io/name=oai-amf
kubectl delete pod -n core-network -l app.kubernetes.io/name=oai-upf
kubectl delete pod -n ran-network -l app=oai-cu
```

## Catatan Penting

- Untuk cluster yang dikelola Argo CD, perubahan sebaiknya masuk lewat Git lalu disinkronkan oleh Argo CD.
- Hindari patch manual live cluster kecuali untuk emergency debugging.
- Jika harus mengubah file host seperti `/etc/cni/net.d/00-multus.conf`, minta persetujuan dulu karena itu di luar direktori repo.
- Pantau resource sebelum restart banyak pod sekaligus, terutama RAM dan Longhorn volume mount.

## Kapasitas dari Hasil Penelitian

| Resource | RPU | Toleransi 5% | Pembulatan |
| --- | --- | --- | --- |
| CPU | 2781 mCPU | 2920 mCPU | 3000 mCPU |
| RAM | 1965 MiB | 2063 MiB | 2100 MiB |

Rumus:

```text
Total CPU = total user x RPU CPU
Total RAM = total user x RPU RAM
Total user = (total resource - idle resource) / RPU
```

Hasil testing dari slide:

| Test | Jumlah | Hasil |
| --- | --- | --- |
| API Testing | 38 API, masing-masing 30 kali | 100% sukses |
| E2E Testing | 38 fungsi, masing-masing 10 kali | 100% sukses |
| UAT Functional | 38 fitur | 100% sukses |
| UAT SUS Score | 30 responden | 65.42 ke 77.1 |

Max capacity E2E connection yang tercatat: 10 user, lalu drop di user ke-11.
