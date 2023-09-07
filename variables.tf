# Matchbox HTTP read-only endpoint
variable "matchbox_http_endpoint" {
  type        = string
  description = "Matchbox HTTP read-only endpoint (e.g. http://matchbox.example.com:8080)"
}

# Matchbox gRPC API endpoint (without the protocol)
variable "matchbox_rpc_endpoint" {
  type        = string
  description = "Matchbox gRPC API endpoint, without the protocol (e.g. matchbox.example.com:8081)"
}

# Fedora CoreOS release stream
variable "os_stream" {
  type        = string
  description = "Fedora CoreOS release stream (e.g. testing, stable)"
  default     = "stable"
}

# Fedora CoreOS version to PXE and install
variable "os_version" {
  type        = string
  description = "Fedora CoreOS version to PXE and install (e.g. 36.20220906.3.2)"
  default     = "38.20230806.3.0"
}

# SSH public key to set as an authorized_key on machines
variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key to set as an authorized_key on machines"
}

# Network configuration
variable "network" {
  type = object({
    gateway    = string
    prefix     = string
    nameserver = string
    domain     = string
  })
  description = "Network configuration"
}

# List of master machine details
variable "master_nodes" {
  type = list(object({
    name         = string
    mac          = string
    interface    = string
    ip           = string
    install_disk = string
  }))
  description = <<EOD
List of master machine details (unique name, identifying MAC address, FQDN, install disk)
[
  { name = "example-master01", mac = "00:00:00:00:00:01", interface = "eth0", domain = "example-master01.example.com", ip = "192.168.0.1", install_disk = "sda" },
  { name = "example-master02", mac = "00:00:00:00:00:02", interface = "eth0", domain = "example-master02.example.com", ip = "192.168.0.2", install_disk = "sda" },
]
EOD
}

# List of worker machine details
variable "worker_nodes" {
  type = list(object({
    name         = string
    mac          = string
    interface    = string
    ip           = string
    install_disk = string
  }))
  description = <<EOD
List of worker machine details (unique name, identifying MAC address, FQDN, install disk)
[
  { name = "example-worker01", mac = "00:00:00:00:00:11", interface = "eth0", domain = "example-worker01.example.com", ip = "192.168.0.11", install_disk = "sda" },
  { name = "example-worker02", mac = "00:00:00:00:00:12", interface = "eth0", domain = "example-worker02.example.com", ip = "192.168.0.12", install_disk = "sda" },
]
EOD
}
