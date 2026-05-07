# 5G RAN Single Node Runbook

Dokumen ini mencatat kondisi deployment 5G OAI yang sedang dipakai di node `awanbaru`.

## Topologi Yang Dipakai

Mode yang aktif sekarang adalah **SINGLE / level1**:

- Namespace core: `core-network`
- Namespace RAN: `ran-network`
- CU: `oai-cu-level1`
- DU: `oai-du-level1`
- UE: `oai-nr-ue-level1`
- RF simulator DU service: `oai-du-rfsim:4043`
- UE tunnel: `oaitun_ue1`

Untuk satu node Kubernetes seperti `awanbaru`, mode yang paling cocok adalah **SINGLE / level1** karena hanya menjalankan 1 CU, 1 DU, dan 1 UE. Mode ini paling ringan dan paling mudah divalidasi end-to-end.

## Arti SINGLE, MDU, MUE, Dan Level

`operation.sh` memakai nama level untuk membedakan skenario Helm release:

- **SINGLE / level1**: 1 CU + 1 DU + 1 UE. Cocok untuk single-node lab dan validasi dasar.
- **MDU / level2**: Multi-DU. 1 CU melayani 2 DU, masing-masing dengan UE sendiri. Dipakai untuk uji banyak gNB-DU/cell.
- **MUE / level3**: Multi-UE. 1 CU + 1 DU melayani lebih dari 1 UE. Dipakai untuk uji beberapa UE pada satu DU.

Nama seperti `oai-du1-level2` dan `oai-du2-level2` berarti DU pertama dan DU kedua pada skenario MDU. Mereka berbeda dari `oai-du-level1` karena `level1` hanya punya satu DU.

## Masalah Yang Sudah Diperbaiki

- Multus default CNI sempat salah path/config, sehingga banyak pod stuck `ContainerCreating`.
- Beberapa NetworkAttachmentDefinition core sempat memakai `ipvlan mode: bridge`; sudah diselaraskan ke `mode: l2`.
- CU/DU sempat beda versi image; disamakan ke `2023.w49`.
- DU RFSIM sempat connect ke `0.0.0.0`; sekarang DU menjadi server RFSIM.
- UE RFSIM sempat mengarah ke IP lama; sekarang memakai service `oai-du-rfsim`.
- UPF sempat tidak punya interface `n3`; pod UPF sudah dibuat ulang setelah Multus benar.
- Route antar-interface yang berada dalam subnet `172.20.0.0/16` dibuat eksplisit:
  - CU ke AMF lewat `n2`
  - CU ke DU lewat `f1`
  - CU ke UPF lewat `n3`
  - UPF balik ke CU lewat `n3`

Pod `core-network/oai-cu-level1-...` yang dulu `CrashLoopBackOff` adalah deployment RAN lama/duplikat di namespace yang salah. Jalur aktif sekarang adalah RAN di namespace `ran-network`.

## Validasi Operasional

Status pod yang diharapkan:

```bash
kubectl -n core-network get pods
kubectl -n ran-network get pods
```

Validasi UE tunnel:

```bash
kubectl -n ran-network exec deploy/oai-nr-ue-level1 -- ip -brief addr show oaitun_ue1
```

Hasil yang diharapkan:

```text
oaitun_ue1 UNKNOWN 12.1.1.100/24 ...
```

Status `UNKNOWN` pada interface TUN normal. Yang penting interface memiliki IP `12.1.1.100/24`.

Validasi ping data-plane UE ke UPF:

```bash
kubectl -n ran-network exec deploy/oai-nr-ue-level1 -- ping -c 4 -W 2 -I oaitun_ue1 12.1.1.1
```

Hasil valid terakhir:

```text
4 packets transmitted, 4 received, 0% packet loss
```

## Catatan ArgoCD

Auto-sync/self-heal ArgoCD untuk `orca-app` sempat dipause agar perbaikan live tidak direvert. Jangan aktifkan kembali self-heal sebelum perubahan chart/manifests ini masuk ke source Git yang dipakai ArgoCD.
