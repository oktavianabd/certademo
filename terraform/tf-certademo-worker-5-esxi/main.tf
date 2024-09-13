terraform {
  required_providers {
    vsphere = {
        source = "hashicorp/vsphere"
        version = "2.6.1"
    }
    # template = {
    #   source = "hashicorp/template"
    #   version = "2.2.0"
    # }
  }
}

provider "vsphere" {
  user = "administrator@vsphere.local"
  password = "P@ssw0rd"
  vsphere_server = "10.63.22.76"
  allow_unverified_ssl = true
}

# provider "template" {
# }

# data template_file "userdata" {
#   template = file("${path.module}/cloud-init.yml")
# }

# data template_file "metadata" {
#   template = file("${path.module}/metadata.yml")
# }

data "vsphere_datacenter" "datacenter" {
  name = "Datacenter01"
  
}

data "vsphere_datastore" "datastore" {
  name = "esxistor1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "cluster01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name = "rocky93-cloudinit"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name = "worker05"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id = data.vsphere_datastore.datastore.id
  num_cpus = 1
  memory = 2048
  guest_id = data.vsphere_virtual_machine.template.guest_id
  # scsi_type = data.vsphere_virtual_machine.template.scsi_type
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label = "disk0"
    size = data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }
  # cdrom {
  #   client_device = true
  # }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
    ]
  }
  extra_config = {
    "guestinfo.metadata" = base64encode(file("${path.module}/metadata.yml"))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata" = base64encode(file("${path.module}/userdata.yml"))
    "guestinfo.userdata.encoding" = "base64"
  }
  # vapp {
  #   properties = {
  #     "metadata" = base64encode(file("${path.module}/metadata.yml"))
  #     "user-data" = base64encode(file("${path.module}/cloud-init.yml"))
  #   }
  # }
  # extra_config = {
  #   "guestinfo.metadata"          = base64encode(data.template_file.metadata.rendered)
  #   "guestinfo.metadata.encoding" = "base64"
  #   "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
  #   "guestinfo.userdata.encoding" = "base64"
  # }
}

