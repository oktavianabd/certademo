####################################
#VARIABLES
####################################

# Credentials

vsphere_server = "vcenter01.certa.systems"
vsphere_username = "administrator@vsphere.local"
vsphere_password = "P@ssw0rd"
vsphere_insecure = true

#vSphere Setting

vsphere_datacenter = "Datacenter01"
vsphere_cluster = "cluster01"
vsphere_datastore = "esxistor1"
# vsphere_folder = ""
vsphere_network = "VM Network"
vsphere_template = "rocky93-cloudinit-template-vapp1"
# vsphere_template = "rocky92-template-vapp"

#Virtual Machine Settings

vm_name = "worker05"
vm_cpus = 1
vm_memory = 2048
# vm_firmware = "efi"
# vm_efi_secure_boot_enabled = true