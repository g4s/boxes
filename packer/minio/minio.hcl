variable "memory" {
    type = string
    default = "2048"
}

variable "vcores" {
    type = string
    default = "2"
}

packer {
    required_plugins = {
        hcloud = {
            version = ">= 1.1.1"
            source  = "github.com/hetznercloud/hcloud"
        },
        virtualbox = {
            version = "~> 1"
            source  = "github.com/hashicorp/virtualbox"
        }
    }
}

source "virtualbox-ovf" "coreos-minio" {
    source_path = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20231204.3.3/x86_64/fedora-coreos-39.20231204.3.3-virtualbox.x86_64.ova"
    checksum = sha256:a10724a0f0955ffc2bfa327f5e8efec07d5904305dd80ee3c75a24f2c5dca26e
    ssh_username =  "core"
    ssh_password = "core"
    guest_additions_mode = "attach"
    vboxmanage = [
        ["modifyvm", "{{.Name}}", "--memory", "${var.memory}"],
        ["modifyvm", "{{.Name}}", "--cpus", "${var.vcores}"],
        ["modifyvm", "{{.Name}}", "--cpuhotplug", "on"],
        ["modifyvm", "{{.Name}}", "--]
    ]
    shutdown_command = "sudo shutdown -h now
}

source "hcloud" "alma-minio" {
    image = "almalinux-9"
}

build {
    sources = [
        "virtualbox-ovf.coreos-minio",
        "hcloud.alma-minio"
    ]

    provisioner "shell" {
        inline = [
            "dnf update * -y",
            "dnf install -y curl",
            "curl https://dl.min.io/server/minio/release/linux-amd64/minio --output minio --silent",
            "chmod +x minio",
            "mv minio /usr/local/bin/"
        ]
    }
}