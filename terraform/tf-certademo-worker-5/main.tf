terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://root@10.63.20.2/system"
}

#Define VM volume
resource "libvirt_volume" "qcow2_volume" {
  count  = var.vm_count
  name   = "${var.vm_name}-${count.index + 5}.qcow2"
  pool   = "images"
  # source = "http://10.63.20.3/download/CentOS-7-x86_64-GenericCloud.qcow2"
  base_volume_name = "Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  # base_volume_name = "Rocky-8-GenericCloud.latest.x86_64.qcow2"
  format = "qcow2"
}

#Define cloud init
data "template_file" "user_data" {
  count    = var.vm_count
  template = file("${path.module}/cloud-init.cfg")

  vars = {
    hostname = "${var.vm_name}-${count.index + 5}"
    domain   = var.domain
  }
}

data "template_file" "network_config" {
  #   count = var.vm_count
  template = file("${path.module}/network-config.cfg")
  #   vars = {
  # 	lastipoctet = "${var.ipaddress}${count.index + 1}"
  #   }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count     = var.vm_count
  name      = "${var.vm_name}-cloudinit-${count.index + 5}.iso"
  user_data = data.template_file.user_data[count.index].rendered
  #   network_config = data.template_file.network_config[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool           = "images"
}

#Define network
# resource "libvirt_network" "network-demo" {
#   name = "network-demo"
#   mode = "bridge"
#   bridge = "br0"
#   # mtu = 1500
#   addresses = ["10.63.20.0/27"]
#   # dhcp {
# 	# enabled = false
#   # }
# }



#Define KVM domain to create
resource "libvirt_domain" "virtual_machine" {
  count     = var.vm_count
  name      = "${var.vm_name}-${count.index + 5}"
  memory    = "2048"
  vcpu      = 2
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    # network_id = libvirt_network.net1.id
    # hostname = "worker03"
    # network_name = "network-demo"
    bridge    = "br0"
    # addresses = ["10.63.20.8"]
    # addresses = ["192.168.20.${var.ipaddress}${count.index + 1}"]
    # wait_for_lease = true
  }

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.qcow2_volume[count.index].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
  }
  graphics {
    type        = "vnc"
    autoport    = true
    listen_type = "address"
  }

}

# Output Server IP

# output "ip" {
# 	value = "${libvirt_domain.virtual_machine.*.network_interface.0.addresses.0}"
# }

output "vm_info" {
  value = [
    for virtual_machine in libvirt_domain.virtual_machine : {
      hostname = virtual_machine.name
      # ip-addr  = virtual_machine.network_interface.0.addresses
    }
  ]
}