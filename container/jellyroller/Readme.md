# jellyroller

This is a simple Fedora based OCI-compliant container for executing jellyroller.
jellyroller by it selfs is a rust-based cli management tool for Jellyfin.

Requirements:
  - pypyr
  - git

If you want speed-up the process you can use a dnf-local package cache on your
build host. 

## Building the Container (simple way)
If you wish to build the container in a simple manner, you can use the provided
pypyr pipeline:

```bash
pypyr ./build.yaml
```

## Using jellyroller
Notice: this documentation will use podman for managing container, but feel free
to use what you want.

Notice: it's recommended to consult the original jellyroller documentation.

jellyroller is packaged inside an OCI-compliant container. Before you can use
it first time, it is mandatory to configure access to your jellyfin instance.

```bash
podman-exec --interactive <container name> jellyroller
```
This will spawn an interactive shell inside the container and call the jellyroller
binary. At first launch you will be asked to configure the jellyfin access.

After this procedure, it`s possible to execute every supported jellyroller command
with a simple invocation. 

```bash
podman-exec <container name> jellyroller <jellyroller cmd>
```
