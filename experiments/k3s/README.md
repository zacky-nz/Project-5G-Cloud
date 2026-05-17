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

## 7. Cek CPU untuk OAI RAN

Image OAI RAN (`oai-gnb` dan `oai-nr-ue`) membutuhkan instruksi CPU AVX2. Cek sebelum deploy CU, DU, dan NR-UE:

```bash
lscpu | grep -i '^Flags' | grep -o 'avx2'
```

Expected:

```text
avx2
```

Jika output kosong, OAI Core masih bisa diuji, tetapi OAI CU/DU/NR-UE akan gagal start dengan exit code `132` (`Illegal instruction`). Untuk menjalankan RAN, ubah CPU VM agar expose AVX2, misalnya CPU mode `host`/`host-passthrough` di hypervisor, lalu restart VM dan cek ulang flag CPU.

## 8. Install Longhorn

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

## 9. Buat namespace OAI

```bash
kubectl create namespace core-network --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace ran-network --dry-run=client -o yaml | kubectl apply -f -
```

Command ini aman dijalankan berulang. Jika namespace sudah ada, `kubectl apply` hanya memastikan object tetap ada.

## 10. Install Multus khusus K3s

K3s memakai path CNI berbeda dari baseline vanilla:

```text
CNI config dir : /var/lib/rancher/k3s/agent/etc/cni/net.d
CNI binary dir : /var/lib/rancher/k3s/data/cni
```

Install plugin CNI tambahan yang dibutuhkan NAD OAI (`ipvlan` dan IPAM `static`):

```bash
CNI_VERSION=v1.7.1
TMPDIR=$(mktemp -d)
curl -fL "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz" \
  -o "$TMPDIR/cni-plugins.tgz"

sudo tar -C /var/lib/rancher/k3s/data/cni -xzf "$TMPDIR/cni-plugins.tgz" \
  ./ipvlan ./macvlan ./static ./ptp ./tuning
sudo chmod 755 /var/lib/rancher/k3s/data/cni/{ipvlan,macvlan,static,ptp,tuning}
rm -rf "$TMPDIR"
```

Karena Multus daemon menjalankan delegate plugin lewat `/opt/cni/bin`, isi juga path itu dan pastikan plugin dasar K3s bukan symlink patah saat dimount ke container:

```bash
for p in bandwidth bridge firewall flannel host-local loopback portmap; do
  sudo rm -f "/var/lib/rancher/k3s/data/cni/$p"
  sudo cp /var/lib/rancher/k3s/data/current/bin/cni "/var/lib/rancher/k3s/data/cni/$p"
  sudo chmod 755 "/var/lib/rancher/k3s/data/cni/$p"
done

sudo mkdir -p /opt/cni/bin
for p in bandwidth bridge cni firewall flannel host-local loopback portmap ipvlan macvlan static ptp tuning multus-shim; do
  if [ -e "/var/lib/rancher/k3s/data/cni/$p" ]; then
    sudo cp -Lf "/var/lib/rancher/k3s/data/cni/$p" "/opt/cni/bin/$p"
    sudo chmod 755 "/opt/cni/bin/$p"
  fi
done
```

Apply manifest Multus K3s:

```bash
kubectl apply -f AN-ORCA-CNF/multus-daemonset-k3s.yml
kubectl rollout status ds/kube-multus-ds -n kube-system --timeout=180s
kubectl get pods -n kube-system -l app=multus -o wide
kubectl get crd network-attachment-definitions.k8s.cni.cncf.io
```

Expected:

```text
kube-multus-ds Running
00-multus.conf ada di /var/lib/rancher/k3s/agent/etc/cni/net.d
```

## 11. Siapkan secret image pull OAI

Chart OAI memakai nama secret `regcred`. Untuk image publik, secret kosong ini cukup agar pod tidak mengeluarkan warning secret hilang.

Di `core-network`, secret bisa dibuat biasa:

```bash
kubectl create secret generic regcred -n core-network \
  --type=kubernetes.io/dockerconfigjson \
  --from-literal=.dockerconfigjson='{"auths":{}}' \
  --dry-run=client -o yaml | kubectl apply -f -
```

Di `ran-network`, chart `oai-nr-ue` punya template `regcred` sendiri. Agar tidak konflik saat `helm install oai-nr-ue`, buat secret kosong dengan metadata ownership Helm untuk release `oai-nr-ue`:

```bash
kubectl create secret generic regcred -n ran-network \
  --type=kubernetes.io/dockerconfigjson \
  --from-literal=.dockerconfigjson='{"auths":{}}' \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl label secret regcred -n ran-network \
  app.kubernetes.io/managed-by=Helm --overwrite

kubectl annotate secret regcred -n ran-network \
  meta.helm.sh/release-name=oai-nr-ue \
  meta.helm.sh/release-namespace=ran-network \
  --overwrite
```

## 12. Values Helm awanbagus

Gunakan override di folder CNF agar semua aset deploy OAI tetap terkumpul di `AN-ORCA-CNF`, tanpa mengubah chart asli baseline `awanbaru`:

```text
AN-ORCA-CNF/k3s-values/oai-5g-basic-awanbagus.yaml
AN-ORCA-CNF/k3s-values/oai-cu-awanbagus.yaml
AN-ORCA-CNF/k3s-values/oai-du-awanbagus.yaml
AN-ORCA-CNF/k3s-values/oai-nr-ue-awanbagus.yaml
```

Render dulu sebelum deploy:

```bash
helm template basic AN-ORCA-CNF/oai-5g-core/oai-5g-basic \
  -n core-network \
  -f AN-ORCA-CNF/k3s-values/oai-5g-basic-awanbagus.yaml >/tmp/oai-basic-k3s-render.yaml

helm template oai-cu AN-ORCA-CNF/user_n/oai-e2e/oai-cu \
  -n ran-network \
  -f AN-ORCA-CNF/k3s-values/oai-cu-awanbagus.yaml >/tmp/oai-cu-k3s-render.yaml

helm template oai-du AN-ORCA-CNF/user_n/oai-e2e/oai-du \
  -n ran-network \
  -f AN-ORCA-CNF/k3s-values/oai-du-awanbagus.yaml >/tmp/oai-du-k3s-render.yaml

helm template oai-nr-ue AN-ORCA-CNF/user_n/oai-e2e/oai-nr-ue \
  -n ran-network \
  -f AN-ORCA-CNF/k3s-values/oai-nr-ue-awanbagus.yaml >/tmp/oai-ue-k3s-render.yaml

rg "172\\.20|awanbaru" /tmp/oai-*-k3s-render.yaml
```

Command `rg` terakhir harus tidak mengeluarkan hasil.

Deploy core dan RAN setelah K3s, Longhorn, dan Multus valid:

```bash
helm upgrade --install basic AN-ORCA-CNF/oai-5g-core/oai-5g-basic \
  -n core-network \
  -f AN-ORCA-CNF/k3s-values/oai-5g-basic-awanbagus.yaml

helm upgrade --install oai-cu AN-ORCA-CNF/user_n/oai-e2e/oai-cu \
  -n ran-network \
  -f AN-ORCA-CNF/k3s-values/oai-cu-awanbagus.yaml

helm upgrade --install oai-du AN-ORCA-CNF/user_n/oai-e2e/oai-du \
  -n ran-network \
  -f AN-ORCA-CNF/k3s-values/oai-du-awanbagus.yaml

helm upgrade --install oai-nr-ue AN-ORCA-CNF/user_n/oai-e2e/oai-nr-ue \
  -n ran-network \
  -f AN-ORCA-CNF/k3s-values/oai-nr-ue-awanbagus.yaml
```

## 13. Urutan deploy aman

Jangan langsung deploy OAI setelah K3s selesai install. Urutan amannya:

1. Install K3s.
2. Verifikasi node `Ready`.
3. Install Helm.
4. Cek CPU `avx2` sebelum deploy OAI RAN.
5. Pastikan keputusan storage: untuk riset ini Longhorn dipakai agar setara dengan `awanbaru`.
6. Install Longhorn dan pastikan pods, StorageClass, dan CSIDriver valid.
7. Install Multus khusus K3s.
8. Cek `NetworkAttachmentDefinition`.
9. Siapkan values Helm K3s dengan IP `172.21.x.x`.
10. Deploy OAI Core via Helm.
11. Deploy CU, DU, NR-UE via Helm jika CPU AVX2 tersedia.
12. Validasi interface `n2`, `n3`, `n4`, `f1`.
13. Validasi UE tunnel `oaitun_ue1` dan ping `12.1.1.1`.

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

## 14. Catatan troubleshooting awal

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

Jika OAI CU, DU, atau NR-UE gagal dengan exit code `132`, cek CPU flag:

```bash
lscpu | grep -i '^Flags'
```

Jika tidak ada `avx2`, itu bukan masalah Helm/Multus. VM harus dipindah ke CPU mode yang expose AVX2 atau image OAI harus dibuild ulang untuk instruksi CPU yang tersedia.
