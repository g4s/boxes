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
  
source "virtualbox-ovf" "homecontrol" {
  source_path = "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20231204.3.3/x86_64/fedora-coreos-39.20231204.3.3-virtualbox.x86_64.ova"
  checksum = sha256:a10724a0f0955ffc2bfa327f5e8efec07d5904305dd80ee3c75a24f2c5dca26e
  ssh_username =  "core"
  ssh_password = "core"
  guest_additions_mode = "attach"
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", "${var.memory}"],
    ]
  shutdown_command = "sudo shutdown -h now
  }
  
build {
  sources = ["virtualbox-ovf.homecontrol"]
  }