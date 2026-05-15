# K3s experiment setup: awanbagus

Dokumen ini dipakai saat menyiapkan VM `awanbagus` sebagai pembanding K3s untuk baseline vanilla Kubernetes/kubeadm di `awanbaru`.

Target komponen yang harus sama secara metodologi:

- Flannel sebagai primary CNI
- Multus sebagai secondary CNI
- Longhorn sebagai storage component
- OAI 5G Core
- OAI CU/DU/NR-UE
- Deploy workload utama memakai Helm

## 0. Prinsip awal

Jangan join `awanbagus` ke cluster `awanbaru`. `awanbagus` harus menjadi cluster K3s single-node sendiri.

Gunakan subnet Multus berbeda dari `awanbaru` agar tidak IP conflict:

```text
awanbaru node IP       : 172.20.0.11
awanbagus node IP      : 172.20.0.25
awanbaru OAI/Multus IP : 172.20.0.0/16
awanbagus OAI/Multus IP: 172.21.0.0/16
```

Catatan: `172.20.0.25` adalah IP VM/node `awanbagus`. Untuk IP tambahan OAI via Multus tetap gunakan `172.21.0.0/16` agar tidak bentrok dengan IP OAI di `awanbaru` seperti `172.20.0.200`, `172.20.0.201`, dan seterusnya.

## 1. Masuk ke VM awanbagus

```bash
ssh ubuntu@awanbagus
```

Pastikan hostname benar:

```bash
hostname
```

Expected:

```text
awanbagus
```

Jika hostname belum benar:

```bash
sudo hostnamectl set-hostname awanbagus
```

## 2. Install package dasar

```bash
sudo apt update
sudo apt install -y git curl wget ca-certificates gnupg lsb-release jq open-iscsi nfs-common
sudo systemctl enable --now iscsid
```

`open-iscsi` penting untuk Longhorn.

## 3. Clone branch riset

Jika repo belum ada di `awanbagus`:

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

Cek branch:

```bash
git branch --show-current
```

Expected:

```text
research/k8s-vs-k3s-helm-minimal
```

## 4. Install K3s single-node

Versi K3s dipin ke Kubernetes `v1.30.14` agar selevel dengan `awanbaru` yang memakai vanilla Kubernetes `v1.30.14`.

K3s default sudah memakai Flannel. Komponen bawaan yang tidak dipakai dalam eksperimen dimatikan:

- Traefik
- ServiceLB
- metrics-server
- local-storage

Install:

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

## 5. Verifikasi K3s

```bash
kubectl get nodes -o wide
kubectl version -o yaml
kubectl get pods -A
kubectl get sc
kubectl get csidrivers
systemctl status k3s --no-pager
```

Expected:

```text
Node awanbagus Ready
Kubernetes version mengandung +k3s
Service k3s active/running
```

Cek komponen bawaan yang dimatikan:

```bash
kubectl get pods -A
```

Yang diharapkan:

- Tidak ada Traefik
- Tidak ada ServiceLB pod
- Tidak ada metrics-server
- Tidak ada local-path-provisioner
- CoreDNS tetap ada
- Flannel/K3s networking aktif

## 6. Install Helm

Jika Helm belum ada:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

## 7. Install Longhorn

Longhorn dipasang juga di K3s agar setara dengan `awanbaru`.

Keputusan saat ini: pakai Longhorn di `awanbagus`, karena baseline `awanbaru` sudah memakai Longhorn untuk PVC MySQL OAI. Jika keputusan riset berubah menjadi tanpa Longhorn, jangan jalankan section ini dan pastikan tidak ada namespace/pod `longhorn-system`.

```bash
helm repo add longhorn https://charts.longhorn.io
helm repo update

kubectl create namespace longhorn-system --dry-run=client -o yaml | kubectl apply -f -

helm install longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --version 1.6.2
```

Tunggu sampai Running:

```bash
kubectl get pods -n longhorn-system
kubectl get storageclass
kubectl get csidrivers
```

Expected:

```text
longhorn-system pods Running
StorageClass longhorn tersedia
CSI driver longhorn.io tersedia
```

Jika `longhorn` belum menjadi default StorageClass, set default:

```bash
kubectl patch storageclass longhorn \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## 8. Buat namespace OAI

```bash
kubectl create namespace core-network --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ran-network --dry-run=client -o yaml | kubectl apply -f -
```

Command ini aman dijalankan berulang. Jika namespace sudah ada, `kubectl apply` hanya memastikan object tetap ada.

## 9. Urutan deploy aman

Jangan langsung deploy OAI setelah K3s selesai install. Urutan amannya:

1. Install K3s.
2. Verifikasi node `Ready`.
3. Install Helm.
4. Pastikan keputusan storage: untuk riset ini Longhorn dipakai agar setara dengan `awanbaru`.
5. Install Longhorn dan pastikan pods, StorageClass, dan CSIDriver valid.
6. Install Multus khusus K3s.
7. Cek `NetworkAttachmentDefinition`.
8. Siapkan values Helm K3s dengan IP `172.21.x.x`.
9. Deploy OAI Core via Helm.
10. Deploy CU, DU, NR-UE via Helm.
11. Validasi interface `n2`, `n3`, `n4`, `f1`.
12. Validasi UE tunnel `oaitun_ue1` dan ping `12.1.1.1`.

Untuk tahap awal, berhenti dulu setelah command berikut sukses:

```bash
kubectl get nodes -o wide
kubectl get pods -A
helm version
kubectl get pods -n longhorn-system
kubectl get storageclass
kubectl get csidrivers
```

Jangan lanjut deploy OAI sebelum K3s, Helm, Longhorn, dan Multus valid.

## 10. Catatan troubleshooting awal

Cek log K3s:

```bash
sudo journalctl -u k3s -f
```

Restart K3s:

```bash
sudo systemctl restart k3s
```

Uninstall K3s jika perlu reset total:

```bash
sudo /usr/local/bin/k3s-uninstall.sh
```

Gunakan uninstall hanya kalau memang mau reset cluster K3s dari awal.
