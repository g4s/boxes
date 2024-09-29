source "vmware" "vdi" {}
source "hcloud" "vdi" {}
source "qemu" "vdi" {}

build {
    sources = [
        "source.vmware-iso.vdi",
        "source.hcloud.vdi",
        "source.qemu.vdi"
    ]

    provisioner "ansible" {
        playbook_file = "./provisioning/vdi.yml
    }
}