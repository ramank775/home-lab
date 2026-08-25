# setup/ansible

Installs k3s on already-running nodes and applies node-level prerequisites.
Entrypoint: `setup.yml`. Inventory lives in `.lab/ansible/hosts.ini` (gitignored).

## Prerequisites

**Controller (workstation)**

- `ansible-core` + the `community.general` collection (`ansible-galaxy collection install community.general`) — used by the `raspberrypi` and `resources` roles.
- SSH reachability and passwordless sudo on every host in the inventory.
- `.lab/ansible/hosts.ini` listing the *current* nodes under `[master]` / `[node]`.

**Nodes**

| Prerequisite | Applied by | Notes |
| --- | --- | --- |
| cgroup memory/cpuset enabled | `raspberrypi` role (`/boot/cmdline.txt`) | Pi only; reboots the host |
| `iptables-legacy` alternatives | `raspberrypi` role | Pi only |
| `open-iscsi`, `nfs-common`, `cifs-utils` | `raspberrypi` role | needed by democratic-csi |
| `fs.inotify.max_user_instances = 8192`<br>`fs.inotify.max_user_watches = 524288` | `sysctl` role (`/etc/sysctl.d/99-k3s-inotify.conf`) | **all nodes**, Pi and VM |

The inotify bump is not optional. The Debian default of 128 instances is a
per-UID budget shared by every pod on the node running as that UID; once it is
exhausted anything using fsnotify fails to start its watcher — Forgejo logs
`failed to create fsnotify watcher: too many open files`. Takes effect
immediately on `sysctl --system`, but a process only creates its watcher at
startup, so restart the affected workload afterwards.

## Running

```sh
# Full setup (Pi nodes only — the k3s/download role fetches the arm64 binary
# and the raspberrypi role edits /boot/cmdline.txt)
ansible-playbook -i .lab/ansible/hosts.ini setup/ansible/setup.yml

# Node prerequisites only. Safe on the amd64 VM nodes, which the rest of this
# tree does not support.
ansible-playbook -i .lab/ansible/hosts.ini setup/ansible/setup.yml --tags sysctl
```
