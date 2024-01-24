// packer template for building a smart home control system

packer {
  required_plugins {
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
      }
    }
  }
  
variable "memory" {
  type = string
  default = "4096"
  }
  
variable "vcpus" {
  type = string
  default = "2"
  }

variable "ansible_rolepath" {
  type = string
  default = "/usr/share/ansible/roles"
}


// set tailscale authentification key in environment
variable "tailscale_auth" {
  type = string
  default = env("TSC_AUTH")
}

source "virtualbox-ovf" "homecontrol" {
  source_path = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20231204.3.3/x86_64/fedora-coreos-39.20231204.3.3-virtualbox.x86_64.ova"
  checksum = sha256:a10724a0f0955ffc2bfa327f5e8efec07d5904305dd80ee3c75a24f2c5dca26e
  ssh_username = "core"
  ssh_password = "core"
  guest_additions_mode = "attach"
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "${var.memory}"],
    ["modifyvm", "{{.Name}}", "--cpus", "${var.vpus}"],
    ["modifyvm", "{{.Name}}", "--cpu-hotplug", "on"],
    ]
  shutdown_command = "sudo shutdown -h now
  }
  
build {
  sources = [
    "virtualbox-ovf.homecontrol"
    ]

  // upload necessary files to image
  provisioner "file" {
    source = "./provisioning/ansible-provisioner.yaml"
    destination = "/tmp/ansible-provisioner.yaml"
    }

  provisioner "file" {
    source = "./provisioning/gilt-overlays.yaml"
    destionation = "/tmp/gilt-overlays.yaml"
    }

  // prepare provisioning
  provisioner "script" {
    inline = [
      "dnf install -y python3 python3-pip python3-gilt ansible",
      "mkdir -p /usr/share/config",
      "mv /tmp/ansible-provisioner.yaml /usr/share/config/local.yaml",
      "mv /tmp/gilt-overlays.yaml /user/share/config/.gilt.yaml",
      "cd /usr/share/config/ && gilt overlay",
      "mkdir -p ${var.ansible_rolepath}",
      "ansible-galaxy collection install containers.podman",
      "ansible-galaxy install --roles-path ${var.ansible_rolepath} https://github.com/g4s/de.seafi.homecontrol.git"
      ]
    }

  provisioner "ansible-local" {
    playbook_file = "/usr/share/config/local.yaml"
    extra_arguments = [
      "--extra-vars", "tailscale_authkey=${var.tailscale_auth}"
      ]
    }
  
  }