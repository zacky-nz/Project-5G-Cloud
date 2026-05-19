# Memory Redeploy awanbagus Ubuntu 22

Dokumen ini adalah catatan singkat untuk deploy ulang VM `awanbagus` baru memakai Ubuntu 22.
Runbook lengkap tetap ada di `experiments/k3s/README.md`; file ini dipakai sebagai pegangan cepat agar langkah migrasi tidak tercampur dengan VM lama Ubuntu 20.

## Jawaban keputusan

Bisa deploy ulang di VM baru Ubuntu 22.

Rekomendasi: buat `awanbagus` sebagai VM baru/fresh install Ubuntu 22, lalu jadikan cluster K3s single-node sendiri. Jangan join `awanbagus` ke cluster `awanbaru`, dan jangan membawa state Kubernetes lama dari VM Ubuntu 20 kecuali memang sedang restore data tertentu.

## Identitas target

| Item | Target |
| --- | --- |
| VM baru | `awanbagus` |
| OS | Ubuntu 22.04 LTS |
| Orchestrator | K3s single-node |
| Kubernetes/K3s | `v1.30.14+k3s2` |
| Primary CNI | Flannel bawaan K3s |
| Secondary CNI | Multus khusus path K3s |
| Storage | Longhorn `v1.6.2` |
| Namespace core | `core-network` |
| Namespace RAN | `ran-network` |
| Repo branch | `research/k8s-vs-k3s-helm-minimal` |

Jika IP `awanbagus` berubah dari catatan lama, sesuaikan semua command `--node-ip`.
Catatan eksperimen sebelumnya memakai:

```text
awanbagus node IP      : 172.20.0.25
awanbagus OAI/Multus IP: 172.21.0.0/16
```

Subnet OAI/Multus `172.21.0.0/16` sengaja dibedakan dari `awanbaru` agar tidak bentrok dengan baseline vanilla Kubernetes yang memakai `172.20.0.0/16`.

## Checklist sebelum install

Pastikan VM baru:

- Hostname diset ke `awanbagus`.
- CPU VM expose `avx2`; OAI RAN bisa gagal `Illegal instruction` kalau tidak ada AVX2.
- Resource ideal mengikuti baseline lab: 16 vCPU, RAM sekitar 23 GiB, disk minimal 100 GiB.
- IP lebih baik dibuat static/DHCP reservation supaya hasil eksperimen tidak berubah-ubah.
- VM lama Ubuntu 20 tidak menjalankan cluster yang sama saat pengujian final.

Command cek awal:

```bash
hostname
lsb_release -a
ip -brief addr
lscpu | grep -i '^Flags' | grep -o 'avx2'
```

Expected:

```text
hostname = awanbagus
Ubuntu = 22.04 LTS
CPU flags mengandung avx2
```

## Urutan redeploy aman

1. Install package dasar.
2. Clone repo dan checkout branch riset.
3. Install K3s single-node.
4. Aktifkan kubeconfig user `ubuntu`.
5. Verifikasi node `Ready`.
6. Install Helm.
7. Install Longhorn.
8. Install plugin CNI tambahan dan Multus untuk K3s.
9. Buat namespace `core-network` dan `ran-network`.
10. Buat secret `regcred`.
11. Render Helm values K3s dan pastikan tidak ada IP `172.20`/`awanbaru`.
12. Deploy OAI Core.
13. Deploy OAI CU, DU, dan NR-UE.
14. Validasi interface Multus, tunnel UE, dan ping UE ke UPF.

## Command inti

Install package dasar:

```bash
sudo apt update
sudo apt install -y git curl wget ca-certificates gnupg lsb-release jq open-iscsi nfs-common
sudo systemctl enable --now iscsid
```

Clone repo:

```bash
cd /home/ubuntu
git clone -b research/k8s-vs-k3s-helm-minimal https://github.com/zacky-nz/Project-5G-Cloud.git
cd /home/ubuntu/Project-5G-Cloud
```

Jika repo sudah ada:

```bash
cd /home/ubuntu/Project-5G-Cloud
git fetch origin
git checkout research/k8s-vs-k3s-helm-minimal
git pull
```

Install K3s. Ganti `172.20.0.25` kalau IP VM baru berbeda:

```bash
curl -sfL https://get.k3s.io -o /tmp/install-k3s.sh

sudo INSTALL_K3S_VERSION="v1.30.14+k3s2" \
  INSTALL_K3S_EXEC="server \
    --node-name awanbagus \
    --node-ip 172.20.0.25 \
    --write-kubeconfig-mode 644 \
    --disable traefik \
    --disable servicelb \
    --disable metrics-server \
    --disable local-storage" \
  sh /tmp/install-k3s.sh
```

Aktifkan kubeconfig:

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config
export KUBECONFIG=~/.kube/config
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
```

Validasi awal:

```bash
kubectl get nodes -o wide
kubectl get pods -A
systemctl status k3s --no-pager
```

Install Helm:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

Install Longhorn:

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update

kubectl create namespace longhorn-system --dry-run=client -o yaml | kubectl apply -f -

helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --version 1.6.2
```

Validasi Longhorn:

```bash
kubectl get pods -n longhorn-system
kubectl get storageclass
kubectl get csidrivers
```

Install Multus dan lanjut deploy OAI mengikuti detail lengkap di:

```text
experiments/k3s/README.md
```

## Validasi wajib setelah deploy OAI

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

Expected akhir:

```text
core-network pods Running
ran-network pods Running
oaitun_ue1 punya IP 12.1.1.100/24
Ping UE -> UPF 12.1.1.1 sukses dengan 0% packet loss
```

## Hal yang jangan sampai lupa

- Jangan pakai subnet OAI/Multus `172.20.0.0/16` di `awanbagus`; pakai `172.21.0.0/16`.
- Jangan lanjut deploy OAI RAN kalau CPU belum expose `avx2`.
- Jangan aktifkan komponen K3s bawaan yang tidak dipakai eksperimen: Traefik, ServiceLB, metrics-server, local-storage.
- Longhorn dipasang agar pembanding K3s setara dengan baseline `awanbaru`.
- Kalau ingin reset total K3s di VM baru, gunakan:

```bash
sudo /usr/local/bin/k3s-uninstall.sh
```

Gunakan uninstall hanya saat memang mau menghapus cluster K3s dari awal.
