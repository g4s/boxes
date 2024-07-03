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