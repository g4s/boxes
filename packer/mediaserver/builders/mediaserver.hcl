variable "memory" {
    type = string
    default = env("PACKER_VMEM")
}

variable "vcpus" {
    type = string
    default = env("PACKER_VCPU")
}

build {
    sources = []

    provisioner "ansible" {
        playbook_file = "../provisioners/mediaserver.yaml"
        ansible_env_vars = []
        role_path = "../provisioners/roles"
    }
}