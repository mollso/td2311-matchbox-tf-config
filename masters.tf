// Define a resource "matchbox_group" for master nodes
resource "matchbox_group" "masters" {
  count    = length(var.master_nodes) // Create a group for each master node
  name     = var.master_nodes[count.index].name
  profile  = matchbox_profile.master-fedora-coreos-install[count.index].name // Associate with a profile
  selector = { mac = var.master_nodes[count.index].mac }                     // Select by MAC address
  metadata = {
    name   = var.master_nodes[count.index].name
    mac    = var.master_nodes[count.index].mac
    domain = format("%s.%s", var.master_nodes[count.index].name, var.network.domain)
  }
}

// Define a resource "matchbox_profile" for master nodes installation
resource "matchbox_profile" "master-fedora-coreos-install" {
  count  = length(var.master_nodes)
  name   = var.master_nodes[count.index].name
  kernel = "/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-kernel-x86_64"
  initrd = [
    "--name main /assets/fedora-coreos/fedora-coreos-${var.os_version}-live-initramfs.x86_64.img"
  ]

  args = [
    "initrd=main",
    "coreos.live.rootfs_url=${var.matchbox_http_endpoint}/assets/fedora-coreos/fedora-coreos-${var.os_version}-live-rootfs.x86_64.img",
    "coreos.inst.install_dev=/dev/${var.master_nodes[count.index].install_disk}",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
  ]

  raw_ignition = data.ct_config.master_nodes[count.index].rendered // Use rendered ignition config
}

// Define a data source "ct_config" to generate Ignition configurations for master nodes
data "ct_config" "master_nodes" {
  count = length(var.master_nodes)
  content = templatefile("fcc/network.yaml", {
    ssh_authorized_key = var.ssh_authorized_key
    hostname           = var.master_nodes[count.index].name
    interface          = var.master_nodes[count.index].interface
    domain             = format("%s.%s", var.master_nodes[count.index].name, var.network.domain)
    ip                 = var.master_nodes[count.index].ip
    gateway            = var.network.gateway
    nameserver         = var.network.nameserver
    prefix             = var.network.prefix
  })
  snippets = [
    templatefile("fcc/hostname.yaml", {
      hostname = format("%s.%s", var.master_nodes[count.index].name, var.network.domain)
    }),
    file("fcc/autologin.yaml")
  ]
  strict = true // Ensure strict Ignition compliance
}
