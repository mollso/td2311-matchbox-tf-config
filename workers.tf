// Define a resource "matchbox_group" for worker nodes
resource "matchbox_group" "workers" {
  count    = length(var.worker_nodes) // Create a group for each worker node
  name     = var.worker_nodes[count.index].name
  profile  = matchbox_profile.worker-fedora-coreos-install[count.index].name // Associate with a profile
  selector = { mac = var.worker_nodes[count.index].mac }                     // Select by MAC address
  metadata = {
    name   = var.worker_nodes[count.index].name
    mac    = var.worker_nodes[count.index].mac
    domain = format("%s.%s", var.worker_nodes[count.index].name, var.network.domain)
  }
}

// Define a resource "matchbox_profile" for worker nodes installation
resource "matchbox_profile" "worker-fedora-coreos-install" {
  count  = length(var.worker_nodes)
  name   = var.worker_nodes[count.index].name
  kernel = "/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-kernel-x86_64"
  initrd = [
    "--name main /assets/fedora-coreos/fedora-coreos-${var.os_version}-live-initramfs.x86_64.img"
  ]

  args = [
    "initrd=main",
    "coreos.live.rootfs_url=${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-rootfs.x86_64.img",
    "coreos.inst.install_dev=/dev/${var.worker_nodes[count.index].install_disk}",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
  ]

  raw_ignition = data.ct_config.worker_nodes[count.index].rendered // Use rendered ignition config
}

// Define a data source "ct_config" to generate Ignition configurations for worker nodes
data "ct_config" "worker_nodes" {
  count = length(var.worker_nodes)
  content = templatefile("fcc/network.yaml", {
    ssh_authorized_key = var.ssh_authorized_key
    hostname           = var.worker_nodes[count.index].name
    interface          = var.worker_nodes[count.index].interface
    domain             = format("%s.%s", var.worker_nodes[count.index].name, var.network.domain),
    ip                 = var.worker_nodes[count.index].ip
    gateway            = var.network.gateway
    nameserver         = var.network.nameserver
    prefix             = var.network.prefix
  })
  snippets = [
    templatefile("fcc/hostname.yaml", {
      hostname = format("%s.%s", var.worker_nodes[count.index].name, var.network.domain)
    }),
    file("fcc/autologin.yaml")
  ]
  strict = true // Ensure strict Ignition compliance
}
