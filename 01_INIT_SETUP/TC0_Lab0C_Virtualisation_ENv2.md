# Chapter 0: Prerequisites — Virtualisation

**Operating Systems — Lab 0C · Adapted by Antonio Clim, PhD**

**v2.1 · Ubuntu Server 24.04 LTS · ENos v6 candidate**

This revision preserves the scope and three architecture figures of the v2.0 teaching document. Commands are examples for the stated environment. Confirm the host architecture, assigned network and installed versions before applying them. The companion Markdown is the editable source of the PDF.

## 0.1 Introduction to Virtualisation

Virtualisation abstracts physical resources — processors, memory and storage — and presents virtual equivalents to applications or guest operating systems. A hypervisor mediates the use of resources by virtual machines. Different kinds of virtualisation have different trust boundaries and performance characteristics.

The earlier edition associated the term with the Latin *virtus* and potentiality. That etymological claim is retained here as an author provenance question; it is not used as a technical definition.

Consider a computer running Windows on which a Linux system must also operate, without dual booting. A virtual machine uses a disk image rather than a dedicated physical partition, a configured allocation of memory and one or more virtual processors. The guest sees a virtual hardware interface. Several guest systems can run on the same physical host, subject to its capacity and the hypervisor's configuration.

## 0.2 Virtual Machines and Containers

A Type 1 (bare-metal) hypervisor operates at the hardware virtualisation layer. A Type 2 (hosted) hypervisor runs with a host operating system. These are useful teaching categories; implementation details, management components and hardware support differ between products.

<!-- FIGURE:type1 -->

<!-- FIGURE:type2 -->

The operating system inside a VM is the **guest OS**. It can be installed from an ISO image, a prepared disk image or a network boot service such as PXE. The administrator remains responsible for security updates, network settings, accounts and permissions.

Virtualisation can improve utilisation and separate service failures: a failure confined to one guest may leave other guests running. **Several VMs on one host do not establish high availability.** Host, storage, power and shared management failures can affect all of them. High availability requires an explicitly designed and tested arrangement of independent failure domains, recovery or failover and suitable storage/network behaviour.

### Containerisation

A Linux container normally runs processes using the host's Linux kernel. It does not contain a separately booted guest kernel. An image packages application files and dependencies; a runtime starts and supervises the resulting processes under configured isolation and resource controls. Docker Engine, containerd and lower-level runtimes have distinct roles. **containerd is a runtime, not a source-code packaging tool.** Linux containers on a non-Linux desktop may use an intervening Linux VM.

<!-- FIGURE:container -->

### Comparison between virtual machines and containers

| Criterion | Virtual machines | Linux containers |
| --- | --- | --- |
| Isolation | Separate guest kernel and a hypervisor boundary | Shared kernel; namespaces and other controls depend on configuration |
| Resource usage | Includes each guest kernel and its services | Can share kernel and image layers; application demand still matters |
| Start-up | Boots or resumes a guest system | Starts workload processes; image retrieval and initialisation may dominate |
| Portability | Requires compatible architecture, devices and hypervisor format | Requires compatible architecture, kernel facilities and runtime |
| Security | Depends on hypervisor, guest, host and configuration | Depends on shared kernel, privileges, runtime and configuration |
| Scalability | Depends on workload, capacity and orchestration | Depends on workload, capacity and orchestration; Kubernetes is one option |

The earlier table's categorical “minutes/seconds”, “high/low” and universal security/scalability rankings were not measurements. A numerical comparison needs a defined workload, hardware, software versions and measurement method. No benchmark result is asserted here.

## 0.3 Virtualisation Solutions

Choose a solution by its supported host/guest architecture, device needs, management model and operational constraints. Image formats and virtual hardware are not universally interchangeable.

- **VMware:** the vSphere/ESXi product family is used for managed virtual infrastructure. Evaluate current support and licensing for the intended deployment; the product name alone does not demonstrate reliability in a specific installation.
- **KVM (Kernel-based Virtual Machine):** virtualisation facilities integrated into the Linux kernel, commonly used with QEMU and management tools. This is different from a keyboard-video-mouse switch. Open-source availability does not remove administration or support costs. The earlier claim of superior scalability over proprietary solutions requires a comparative benchmark and remains an author evidence question.
- **Xen:** an open-source hypervisor project associated with the Linux Foundation. Its architecture and suitability should be assessed for the actual workload. The earlier unconditional performance advantage is not treated as an established result.
- **Hyper-V:** Microsoft's virtualisation platform, available in supported Windows editions and server products. Check the edition and processor requirements of the actual host.
- **VirtualBox:** Oracle's virtualisation product for supported desktop host platforms. Match the guest architecture to the supported host architecture; consult the version-specific platform matrix [1].
- **Docker and containerd:** tools for building/managing container images and operating container workloads. They do not supply an independent guest kernel for each Linux container. containerd manages container lifecycle and image/runtime services.
- **Kubernetes:** a container orchestration platform using clusters, nodes and pods, with facilities for scheduling, scaling and service management. Orchestration alone is not evidence that a workload has met its availability target.

## 0.4 IaaS — Infrastructure as a Service

IaaS supplies resources such as virtual instances, block storage and networking through service interfaces. The infrastructure can use hypervisors, software-defined networks and orchestration platforms such as OpenStack, Apache CloudStack or OpenNebula. Responsibility for guest configuration and application operation remains defined by the service arrangement.

## 0.5 VM and Container Configuration

A new VM requires suitable network configuration, accounts, permissions and credentials. A prepared image may supply defaults but these must be checked for the deployment. Avoid cloning credentials or host identity unintentionally.

**cloud-init** can obtain instance metadata and configure networking, users and other initial settings. In Kubernetes, Init Containers run before the main application containers; they are a different mechanism and do not replace all VM initialisation responsibilities.

SSH host keys identify the server to a client. User authentication keys serve a different role and require an explicit custody and authorisation arrangement. Generate or provision unique host identity when creating a new instance; do not blindly regenerate the keys of a running system whose identity clients already trust.

`/etc/machine-id` normally contains a 128-bit machine identifier. It is not an SSH key or a guarantee of uniqueness after an improperly prepared clone. Image preparation must follow the operating system's machine identity procedure.

### Virtualisation extensions

On an x86 Linux host, `vmx` and `svm` indicate CPU virtualisation features visible to that environment. Their presence is **not a complete hypervisor acceptance test**: firmware settings, host policy, nested virtualisation and the installed hypervisor can still matter. The x86 `lm` flag concerns long mode; it is not an ARM check. ARM64 hosts use an ARM64 compatibility route rather than these x86 flags.

```bash
# Read-only checks on an x86 Linux host; output varies by machine.
grep -cE 'vmx|svm' /proc/cpuinfo
lscpu
```

Confirm the chosen hypervisor can create and boot the intended guest. Record the host architecture, hypervisor version, image architecture and observed boot result. A CPU flag count alone does not establish this.

### Glossary

- **Application container:** workload processes with packaged application files, operating under runtime and kernel controls; normally no independent guest kernel.
- **Machine ID:** an operating system identity value, normally stored in `/etc/machine-id`; cloning procedures must preserve uniqueness where required.
- **Guest drivers / agents:** guest-side components providing features such as time synchronisation or shared folders, depending on the hypervisor.
- **SSH host keys:** server identity keys used in the SSH protocol; they are distinct from a student's user authentication keys.
- **Virtual machine:** an execution environment presenting virtual hardware to a guest operating system.

## Practical Section: Installing Ubuntu Server 24.04 LTS

### A. Preparing VirtualBox

Use the Ubuntu **24.04 LTS Server** image for the architecture actually supported by the host and hypervisor. The general download page may default to a newer release: deliberately select 24.04 and verify its published checksum [2–3]. Do not rely on an invented or unversioned local ISO filename.

- **Intel/AMD x86-64 host:** use a supported VirtualBox build with an **amd64** guest image.
- **Apple Silicon / supported ARM64 host:** use the corresponding supported VirtualBox ARM64 route and an **arm64** guest image. An amd64 image is not interchangeable with arm64 in this route. Consult the VirtualBox 7.2 platform matrix [1].
- **Unsupported host/guest combination:** use the supported course route for that host; do not assume that changing the VM display name converts the architecture.

1. Open VirtualBox and create a new VM. Use a local name such as `srv1033`, select the matching Linux/Ubuntu architecture and choose manual installation if the guide's screens are required.
2. Allocate memory while leaving sufficient capacity for the host. Canonical documents **1.5 GB as the minimum for Ubuntu 24.04 amd64 ISO installation and 3 GB or more as a suggested minimum** [2]. A practical course configuration is **4 GB if the host permits**; this is a recommendation, not a measured universal requirement. Other architectures or workloads can require more.
3. Create a dynamically allocated virtual disk. **25 GB or more** is the documented suggested minimum for general use [2]; ensure enough real host free space. Dynamic allocation does not create physical capacity.
4. Attach the downloaded ISO to the VM's virtual optical drive. Its controller type and the wizard layout depend on the version; do not require an IDE controller if the supported VM uses another one.
5. Use **NAT** for an isolated initial installation unless the lab explicitly requires and permits a bridged network. Bridged networking exposes the guest on the local network and may be blocked by institutional or Wi-Fi controls. For SSH under NAT, configure an explicit host port forwarding rule; under approved bridging, use the assigned guest address. Do not disable the host firewall wholesale.

### B. Installing Ubuntu Server 24.04 LTS

Ubuntu Server 24.04 LTS uses the Subiquity installer. It has a five-year standard security maintenance period; expanded or extended coverage is a separate service and must not be inferred from “LTS” alone [4]. Screen wording and the kernel version may vary with the point release.

1. Start the VM and select **Try or Install Ubuntu Server**.
2. Select the language and keyboard layout. English is used in this course material.
3. Choose the server installation without a desktop environment.
4. Inspect the detected network. A DHCP address appears only if that network provides DHCP; do not invent an address if it does not.
5. Leave the proxy field empty unless the lab supplies a required proxy.
6. Accept an appropriate Ubuntu mirror offered for the selected architecture, or the lab's specified mirror.
7. Select the intended **virtual disk**. Review the partitioning/LVM proposal.
8. Confirm the disk write only after checking that it is the disposable VM disk; existing data on that selected disk is overwritten.
9. Create the account. Use an OS-valid username beginning with a lower-case letter and a unique password. Keep the academic identifier separate from the Unix login if its format is incompatible.

```text
Your name:   Student SOP
Server name: srv1033
Username:    climantonio
Password:    choose a unique password; do not use a shared example
Academic identifier, if requested separately: 1033_climantonio
```

10. Select **Install OpenSSH server** if the lab requires SSH. Add no optional featured packages unless needed for the exercise.
11. Finish installation, reboot and detach the ISO when prompted. Confirm the guest boots from its virtual disk.

### C.1 First login and basic commands

Log in using the account created during installation. These commands inspect the current machine; outputs are deliberately not fabricated as an expected student's result.

```bash
whoami
hostname
date
ip -brief address
ip route
```

For the example account, `whoami` should report `climantonio`. Network interface names and addresses must come from the actual output. An address such as `192.168.1.105` in a worked example is not an allocation to your VM.

### C.2 Connecting via SSH

From the host, use a terminal on Linux/macOS or OpenSSH in PowerShell on Windows. With approved bridging, use the observed assigned address. With a NAT forwarding rule, use that rule's host address and port.

```bash
# Example only: replace the address with the VM's assigned address.
ssh climantonio@192.168.1.105

# Example NAT forwarding: host TCP 2222 -> guest SSH 22, if configured.
ssh -p 2222 climantonio@127.0.0.1
```

Check the server host-key fingerprint against the VM console or the trusted lab information before accepting a new identity. An unexpected changed fingerprint requires investigation; do not disable host-key checking.

Use `sudo` for the specific administrative command that needs it. `sudo -i` starts a root shell when that is intentionally required; leave it with `exit`. Ubuntu normally disables direct password login to the root account. `sudo` normally requests the current user's password under the configured policy.

### C.3 Setting the hostname

The display name in VirtualBox and the guest hostname are separate. Use a valid lower-case host label such as `srv1033` or the course's valid mapping. An academic identifier containing underscores is not used verbatim as the static hostname.

```bash
hostnamectl
sudo hostnamectl set-hostname srv1033
cat /etc/hostname
```

Changing a hostname does not create a DNS record. Do not invent a `.local` domain or imply that another machine can resolve the name without a corresponding name-resolution arrangement.

### C.4 Static IPv4 configuration with Netplan

**This is an optional controlled lab exercise.** Keep working DHCP unless a static address is assigned or reserved for this VM by the network owner. Reusing the currently leased address without a reservation can create a conflict later. Confirm the address/prefix, gateway, DNS servers and interface name first. Retain console access before changing the interface used by SSH.

1. Inspect the effective configuration with `sudo netplan get` and inspect the existing YAML files in `/etc/netplan/`. Other Netplan search directories and lexicographical merge order can affect the result [5].
2. Establish who owns the configuration. If cloud-init generates it, use the intended cloud-init configuration mechanism. For a disposable lab VM explicitly transferred to local manual management, cloud-init's networking can be disabled using `network: {config: disabled}` in an appropriate `/etc/cloud/cloud.cfg.d/` file [6]. Back up the original and record that ownership change. Do not silently fight an active cloud provisioning service.
3. Edit the **single authoritative configuration for this interface**. Do not leave a later file re-enabling DHCP or merging duplicate addresses/routes. Keep backups outside the active `*.yaml` search set. The name below is illustrative; use the actual authoritative filename.

```yaml
# Example only after these values have been assigned to this lab VM.
# /etc/netplan/60-lab-static.yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: false
      addresses:
        - 192.168.1.105/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [192.168.1.1]
```

This is an IPv4 example. IPv6 Router Advertisements and DHCPv6 require a separate deliberate decision; the example does not claim to disable or configure them. The DNS address is also illustrative and must be replaced by the assigned resolver.

```bash
sudo netplan get
sudo netplan generate
sudo netplan try --timeout 120
# Inspect from the console / another permitted session before confirming:
ip -brief address
ip route
resolvectl status
```

`generate` validates and generates backend configuration; it is not a connectivity test. `try` offers a timed confirmation/rollback path [7]. Verify actual connectivity and the resulting configuration. Its documented rollback limitations mean that a timeout is not proof that every change was undone; inspect the state from the console and restore the saved configuration if necessary. Do not proceed with an unverified remote `apply` as the first test.

### C.5 Package management

Ubuntu uses APT. Review package changes and install only what the lab needs. The following commands are to be run by the operator on the intended VM, not on an unrelated host.

```bash
sudo apt update
sudo apt upgrade
sudo apt install vim tmux mc htop net-tools
```

Read the proposed actions before confirming. Some updates require a reboot. `ip` from iproute2 is used in the earlier network examples; `net-tools` is optional for exercises that discuss its older commands.

## Verification record for this lab

Record the host/guest architecture, hypervisor version, ISO filename and checksum, allocated resources, successful guest boot, valid account/hostname, actual network path and an SSH connection with the expected host key. For the optional static-address exercise, also record the assigned values, configuration ownership, effective `netplan get` result and observed connectivity after confirmation. Static reading of this guide is not evidence that these host-specific steps have run.

## Sources and revision notes

Official sources checked on 17 November 2026. Their applicability remains tied to the versions and architectures stated above.

1. Oracle. *VirtualBox 7.2 User Guide — Introduction and supported platforms*. https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/Introduction.html
2. Canonical. *Ubuntu Server system requirements* (24.04 LTS amd64 figures). https://ubuntu.com/server/docs/system-requirements/
3. Canonical. *Ubuntu Server downloads*. https://ubuntu.com/download/server
4. Canonical. *Ubuntu release cycle*. https://ubuntu.com/about/release-cycle
5. Netplan. *netplan-generate — Handling multiple files*. https://netplan.readthedocs.io/en/stable/netplan-generate/
6. Canonical. *cloud-init network configuration*. https://docs.cloud-init.io/en/latest/reference/network-config.html
7. Netplan. *netplan-try*. https://netplan.readthedocs.io/en/latest/netplan-try/

Changes from v2.0: kept the VM/container/IaaS teaching sequence and all three figure topics; corrected architecture selection, username, memory/storage guidance, SSH identity handling, network ownership/DHCP merging and availability/performance claims. Added selectable text, document language, heading bookmarks, marked structural content and figure descriptions. The PDF is not certified as PDF/UA and a screen-reader acceptance test remains outstanding.
