variable "memory" {
    type = string
    default = env("PACKER_VMEM")
}

variable "vcpus" {
    type = string
    default = env("PACKER_VCPU")
}

variable "disksize" {
    type = string
    default = env("PACKER_DISK")
}

variable "vmname" {
    type = string
    default = env("PACKER_VMNAME")
}

source "qemu" "mediaserver" {
    iso_url = "${var.isourl}
    iso_checksum = "${var.isochecksum}
    output_directory =
    disk_size = ${var.disksize}
    format = "qcow2"
    accelerator = "kvm"
    ssh_username = "core"
    ssh_password = "core"
    vm_name = "${var.vmname}"

}

build {
    sources = ["source.qemu.mediaserver"]

    provisioner "ansible" {
        playbook_file = "../provisioners/mediaserver.yaml"
        role_path = "../provisioners/roles"
    }
}