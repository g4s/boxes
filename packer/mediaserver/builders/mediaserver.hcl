build {
    sources = []

    provisioner "ansible" {
        playbook_file = "../provisioners/mediaserver.yaml"
        ansible_env_vars = []
        role_path = "../provisioners/roles"
    }
}