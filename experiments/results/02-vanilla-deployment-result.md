# Vanilla deployment result: awanbaru

Tanggal validasi: 2026-05-15 UTC

## Ringkasan

| Item | Hasil |
| --- | --- |
| Host | awanbaru |
| Node IP | 172.20.0.11 |
| Kubernetes | v1.30.14 |
| Runtime | containerd://1.7.28 |
| Storage component | Longhorn v1.6.2 |
| Core namespace | core-network |
| RAN namespace | ran-network |
| Status core OAI | Running |
| Status RAN OAI | Running |
| Multus interface | OK |
| UE registered | OK |
| PDU/dataplane | OK |
| Ping UE to UPF tunnel | OK, 4/4 received, 0% packet loss |

## Hasil setelah recovery restart

Recovery dilakukan dengan urutan:

1. Restart `oai-upf`
2. Restart `oai-smf` dan `oai-amf`
3. Restart `oai-cu-level1`, `oai-du-level1`, dan `oai-nr-ue-level1`

Semua deployment kembali `Running`.

## Interface hasil validasi

| Komponen | Interface | Hasil |
| --- | --- | --- |
| UPF | n3 | 172.20.0.201/16 |
| UPF | n4 | 172.20.0.202/16 |
| CU | n2 | 172.20.0.210/16 |
| CU | n3 | 172.20.0.211/16 |
| CU | f1 | 172.20.0.212/16 |
| DU | f1 | 172.20.0.213/16 |
| NR-UE | oaitun_ue1 | 12.1.1.100/24 |

## Functional test

| Test | Hasil |
| --- | --- |
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
| PDU Session Active | OK, UPF has PDR/FAR for UE `12.1.1.100` |
| oaitun_ue1 muncul | OK |
| Ping 12.1.1.1 sukses | OK, 4 transmitted, 4 received |

## Runtime resource snapshot

| Metrik | Nilai |
| --- | --- |
| RAM total | 22 GiB |
| RAM used after OAI | 5.7 GiB |
| RAM available | 16 GiB |
| Disk root size | 97 GiB |
| Disk root used | 62 GiB |
| Disk root available | 36 GiB |
| Disk root usage | 64% |
| Pod count all namespaces | 37 |
| Container count | 39 |
| Image count | 41 |

## Catatan Longhorn

Longhorn aktif di `awanbaru` dan PVC `core-network/basic-mysql` memakai StorageClass `longhorn` dengan kapasitas 8Gi. Karena itu Longhorn diperlakukan sebagai komponen environment pendukung, bukan komponen yang dihapus dari baseline.

Saat membandingkan dengan K3s, `awanbagus` harus menjalankan Longhorn juga agar hasil resource tidak berat sebelah.

## Catatan yang belum final

- Resource snapshot di atas mencakup overhead Longhorn.
- Idle resource belum valid sebagai baseline bersih karena OAI dan Longhorn sudah berjalan ketika snapshot diambil.
- NR-UE sempat restart 1 kali saat rollout, lalu tunnel `oaitun_ue1` muncul dan ping sukses.
- Helm release `v1-cu` masih perlu distandarkan karena statusnya `failed`, meskipun deployment CU sekarang Running.
