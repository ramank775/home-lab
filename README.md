# Home Lab

This repo contains the setup code for home lab of Raspberry pi cluster running k3s with Truenas as storage system.

## Setup

Current setup includes:

Hardware:

- 3 x Raspberry pi 4B 4GB
- 3 x 64GB USB 3.0 Pendrives
- 1 x TP-Link 8-Port Gigabit Ethernet
- 1 x Anker 6-Port USB wall charger
- 4 x RJ45 CAT 7 Gigabit Ethernet Patch cable
- 3 x USB Type C cable
- 1 x Micro HDMI cable (optional)
- 1 x SD card (optional)

Truenas System
- 1 x ASUS PRIME H410M-E
- 1 x i3 10th Gen CPU
- 2 x 8GB RAM
- 1 x 16GB Intel Optane M10
- 1 x 128GB SSD
- 3 x 1TB HDD

Setup Raspberry PI:

- Download 64-bit Raspberry pi os (Currently in beta) from [here](https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2020-08-24/2020-08-20-raspios-buster-arm64.zip) or latest version available.
- Prepare bootable disk on pendrives using [Raspberry pi imager](https://downloads.raspberrypi.org/imager/imager_1.5.exe). Select `"Choose OS -> Use Custom -> Choose your downloaded image from previous step"`.
- Add empty `ssh` file under boot folder.
- Add `wpa_supplicant.conf` if you are setting up pi with wifi.

  ```
  ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
  update_config=1
  country=<Insert 2 letter ISO 3166-1 country code here>

  network={
      ssid="<Name of your wireless LAN>"
      psk="<Password for your wireless LAN>"
  }
  ```

  Full description to setup raspberry pi headless with wifi [here](https://www.raspberrypi.org/documentation/configuration/wireless/headless.md)

- If Pi is not able to boot and stuck in restart loop, with green light blink 4 times. That means Pi unable to find bootable devices attached.

  - One of possible reason is that Raspberry pi firmware is not update to date.
  - To update firmware create a bootable sdcard with Raspberry pi 4 EERPROM boot recovery. Select `"Choose OS -> Misc utility images -> Raspberry Pi 4 EEPROM boot recovery"`.
  - Boot the raspberry pi using sd card and attach hdmi cable. Wait for screen to turn green, which mean success.
  - Reboot the pi using bootable Pendrive

- SSH into the Raspberry pi and set following options using rasp-config
  - password
  - hostname
  - expand file system to use full storage
  - disable desktop mode
- Enable static IP address to prevent IP address change dynamically.

### Setup using Ansible and Terraform

- Prepare ansible group_vars from [sample](setup/inventories/sample/)
- Run ansible playbook to configure raspberry pi and K3s 
```
  $ ansible-playbook ./setup/setup.yml -i {ansible-dir-with-hosts.ini}
```
- Rerun if anything fails

### Manual Setup


- Run `sudo apt update` to update the packages.
- Enabling legacy iptables on Raspbian Buster.

  Raspbian Buster defaults to using nftables instead of iptables. K3S networking features require iptables and do not work with nftables.

  Follow the steps below to switch configure Buster to use legacy iptables:

  ```sh
  sudo iptables -F
  sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
  sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
  sudo reboot
  ```

- Enabling cgroups for Raspbian Buster.

  Standard Raspbian Buster installations do not start with cgroups enabled. K3S needs cgroups to start the systemd service. cgroupscan be enabled by appending cgroup_memory=1 cgroup_enable=memory to /boot/cmdline.txt.

  example of /boot/cmdline.txt

  ```txt
  console=serial0,115200 console=tty1 root=PARTUUID=58b06195-02 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait cgroup_memory=1 cgroup_enable=memory
  ```

  Follow complete instruction from [here](https://rancher.com/docs/k3s/latest/en/advanced/#enabling-legacy-iptables-on-raspbian-buster)

- Install K3s server on master Pi
  ```sh
  curl -sfL https://get.k3s.io | sh - --disable servicelb
  ```
- Copy node token of master
  ```sh
  cat /var/lib/rancher/k3s/server/node-token
  ```
- Install K3s agent on slaves Pi
  ```sh
  curl -sfL https://get.k3s.io | K3S_URL=https://myserver:6443 K3S_TOKEN=mynodetoken sh -
  ```
  Note: Follow complete instruction from [here](https://rancher.com/docs/k3s/latest/en/) to setup k3s.
- Run `kubectl get nodes` to verify all nodes has joined the cluster.
- Copy `/etc/rancher/k3s/k3s.yaml` from Master Pi to access cluster from other system.

- Install democratic-csi if using external storage solution.

- Install longhorn for persistent volume (Optional)

  Make sure you have `open-iscsi` install in all of the nodes

  ```sh
  sudo apt-get update;sudo apt-get install -y open-iscsi
  ```

  ```sh
  kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
  ```

- Install metallb

  ```sh
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
  kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
  ```

- Install System upgrade operator

  ```sh
  kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
  kubectl apply -f system/upgrade/plan.yaml
  ```

- Install kubernetes dashboard
  ```sh
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
  ```
  Create service account and cluster role binding for kubernetes dashboard
  ```sh
  kubectl create serviceaccount dashboard -n default
  kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard
  ```
  Get Login Token
  ```sh
  kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode
  ```

## How to install current workload

- Download terraform cli and add it to system path. Download cli from [here](https://www.terraform.io/).
- Clone this repo to local system.
- Change directory to deployment
  ```sh
  cd deployment
  ```
- Copy `values.local.tf.tmpl` to `values.local.tf` and update variables default value if requried.
- Copy k3s cluster config to `deployment/.kube/kube_config`.
- Run initialize terraform in deployment repo.
  ```sh
  terraform init
  ```
- Verify workload to be added by running
  ```sh
  terraform plan
  ```
- Apply the terraform plan by running
  ```sh
  terraform apply --auto-approve
  ```

### Current workload

- Message broker [NATS](https://nats.io/).
- Nats http producer

  A node express application which expose an http endpoint to publish message into message broker.

- Slack notifier

  A node application listening to channel to message to be send on the slack using slack webhook endpoint.

- Public ip monitor

  Cron which run hourly to check if the public ip has changed or not. If public ip change it publish message into message broker with old and new public IP.

- Blog feature posts

  Cron which run at mid night to compute the top blogs in terms of views and update them as featured blogs for [https://blog.one9x.org](https://blog.one9x.org)

- Pihole

  DNS level network add blocker. It is used for local dns server

- Mail Server (Partially)
  
  Running mail server partially (expect postfix, opendkim).