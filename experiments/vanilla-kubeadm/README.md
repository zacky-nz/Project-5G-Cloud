# Vanilla kubeadm baseline: awanbaru

Baseline ini dipakai untuk eksperimen vanilla Kubernetes/kubeadm sebelum hasilnya dibandingkan dengan K3s di VM `awanbagus`.

## Identitas cluster

| Item | Nilai |
| --- | --- |
| VM/host | awanbaru |
| Node | awanbaru |
| Node IP | 172.20.0.11 |
| Orchestrator | Vanilla Kubernetes/kubeadm |
| Kubernetes version | v1.30.14 |
| Container runtime | containerd 1.7.28 |
| Primary CNI | Flannel |
| Secondary CNI | Multus |
| Storage component | Longhorn |
| Longhorn version | v1.6.2 |
| Mode | Single-node |

## Namespace eksperimen utama

| Namespace | Fungsi |
| --- | --- |
| core-network | OAI 5G Core |
| ran-network | OAI CU/DU/NR-UE |
| kube-system | kubeadm control-plane, kube-proxy, CoreDNS, Multus |
| kube-flannel | Flannel CNI |
| longhorn-system | Longhorn storage |

## Keputusan Longhorn

Longhorn tetap dipakai pada baseline `awanbaru` karena sudah aktif dan PVC MySQL OAI memakai storage class `longhorn`. Untuk menjaga fairness, environment K3s `awanbagus` harus dipasang Longhorn juga sebelum data final dibandingkan.

## Workload OAI

Core network:

- basic-mysql
- oai-amf
- oai-ausf
- oai-nrf
- oai-smf
- oai-udm
- oai-udr
- oai-upf

RAN:

- oai-cu-level1
- oai-du-level1
- oai-nr-ue-level1

## Validasi wajib

```bash
kubectl get pods -n core-network
kubectl get pods -n ran-network
kubectl get network-attachment-definitions -A
kubectl exec -n core-network deploy/oai-upf -- ip -brief addr show n3
kubectl exec -n core-network deploy/oai-upf -- ip -brief addr show n4
kubectl exec -n ran-network deploy/oai-cu-level1 -- ip -brief addr show n2
kubectl exec -n ran-network deploy/oai-cu-level1 -- ip -brief addr show n3
kubectl exec -n ran-network deploy/oai-cu-level1 -- ip -brief addr show f1
kubectl exec -n ran-network deploy/oai-du-level1 -- ip -brief addr show f1
kubectl exec -n ran-network deploy/oai-nr-ue-level1 -- ip -brief addr show oaitun_ue1
kubectl exec -n ran-network deploy/oai-nr-ue-level1 -- ping -c 4 -W 2 -I oaitun_ue1 12.1.1.1
```

## Recovery order

```bash
kubectl -n core-network rollout restart deploy/oai-upf
kubectl -n core-network rollout status deploy/oai-upf --timeout=180s

kubectl -n core-network rollout restart deploy/oai-smf deploy/oai-amf
kubectl -n core-network rollout status deploy/oai-smf --timeout=180s
kubectl -n core-network rollout status deploy/oai-amf --timeout=180s

kubectl -n ran-network rollout restart deploy/oai-cu-level1 deploy/oai-du-level1 deploy/oai-nr-ue-level1
kubectl -n ran-network rollout status deploy/oai-cu-level1 --timeout=240s
kubectl -n ran-network rollout status deploy/oai-du-level1 --timeout=240s
kubectl -n ran-network rollout status deploy/oai-nr-ue-level1 --timeout=240s
```

## Catatan cleanup sebelum data final

- `longhorn-system` berjalan di cluster ini dan sekarang dianggap bagian dari environment pendukung. Pastikan Longhorn juga aktif di `awanbagus`.
- Ada deployment RAN lama di `core-network` yang diskalakan 0 dan berlabel `argocd.argoproj.io/instance=orca-app`. Resource ini tidak menjalankan pod, tetapi sebaiknya dibersihkan atau dicatat sebagai sisa eksperimen lama sebelum laporan final.
- Helm release `v1-cu` berstatus `failed` karena upgrade pernah mencoba mengganti selector immutable. Deployment CU saat ini Running, tetapi release Helm perlu distandarkan sebelum klaim reproducible deployment.
