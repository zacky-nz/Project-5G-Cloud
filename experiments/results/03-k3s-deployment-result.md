# K3s deployment result: awanbagus

Tanggal validasi: 2026-05-17 UTC

## Ringkasan

| Item | Hasil |
| --- | --- |
| Host | awanbagus |
| Node IP | 172.20.0.25 |
| Kubernetes | v1.30.14+k3s2 |
| Runtime | containerd://1.7.27-k3s1 |
| Storage component | Longhorn v1.6.2 |
| Core namespace | core-network |
| RAN namespace | ran-network |
| Status core OAI | Running |
| Status RAN OAI | Running |
| Multus interface | OK |
| UE registered | OK |
| PDU/dataplane | OK |
| Ping UE to UPF tunnel | OK, 4/4 received, 0% packet loss |

## Helm release

| Release | Namespace | Status | Chart |
| --- | --- | --- | --- |
| basic | core-network | deployed | oai-5g-basic-v2.0.0 |
| longhorn | longhorn-system | deployed | longhorn-1.6.2 |
| oai-cu | ran-network | deployed | oai-cu-level1-2.0.0 |
| oai-du | ran-network | deployed | oai-du-level1-1.0.0 |
| oai-nr-ue | ran-network | deployed | oai-nr-ue-level1-2.0.0 |

## Interface hasil validasi

| Komponen | Interface | Hasil |
| --- | --- | --- |
| UPF | n3 | 172.21.0.201/16 |
| UPF | n4 | 172.21.0.202/16 |
| UPF | tun0 | 12.1.1.1/24 |
| CU | n2 | 172.21.0.210/16 |
| CU | n3 | 172.21.0.211/16 |
| CU | f1 | 172.21.0.212/16 |
| DU | f1 | 172.21.0.213/16 |
| NR-UE | net1 | 172.21.1.214/24 |
| NR-UE | oaitun_ue1 | 12.1.1.100/24 |

## Functional test

| Test | Hasil |
| --- | --- |
| K3s node Ready | OK |
| CoreDNS Running | OK |
| Longhorn Running | OK |
| StorageClass longhorn default | OK |
| CSIDriver longhorn tersedia | OK |
| Multus daemonset Running | OK |
| NetworkAttachmentDefinition tersedia | OK |
| AMF Running | OK |
| SMF Running | OK |
| UPF Running | OK |
| CU Running | OK |
| DU Running | OK |
| NR-UE Running | OK |
| Interface n2 muncul | OK |
| Interface n3 muncul | OK |
| Interface n4 muncul | OK |
| Interface f1 muncul | OK |
| UE Registered | OK, AMF shows `5GMM-REGISTERED` |
| oaitun_ue1 muncul | OK |
| Ping 12.1.1.1 sukses | OK, 4 transmitted, 4 received |

## Runtime resource snapshot

| Metrik | Nilai |
| --- | --- |
| CPU | 16 vCPU |
| CPU model | AMD Ryzen Threadripper 3970X 32-Core Processor |
| CPU AVX2 | Available |
| RAM total | 22 GiB |
| RAM used after OAI | 5.2 GiB |
| RAM available | 16 GiB |
| Disk root size | 97 GiB |
| Disk root used | 12 GiB |
| Disk root available | 86 GiB |
| Disk root usage | 12% |
| Pod count all namespaces | 32 |
| Running container count | 34 |
| Image count | 26 |

## Catatan Longhorn

Longhorn aktif di `awanbagus` dan PVC `core-network/basic-mysql` memakai StorageClass `longhorn` dengan kapasitas 8Gi. Ini mengikuti baseline `awanbaru`, sehingga perbandingan K3s vs vanilla Kubernetes/kubeadm tetap memakai komponen storage pendukung yang sama.

## Catatan yang belum final

- Snapshot ini diambil setelah workload OAI, Multus, dan Longhorn sudah berjalan, jadi belum mewakili idle cluster kosong.
- Beberapa pod Longhorn/CoreDNS memiliki restart historis setelah node/service recovery, tetapi pada saat validasi semua pod berada pada status `Running`.
- Subnet Multus sengaja berbeda dari `awanbaru`: `awanbagus` memakai `172.21.0.0/16` dan `172.21.1.0/24` untuk menghindari IP conflict.
