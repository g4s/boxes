# jellyroller

This is a simple Fedora based OCI-compliant container for executing jellyroller.
jellyroller by it selfs is a rust-based cli management tool for Jellyfin.

Requirements:
  - [pypyr](https://pypyr.io)
  - git

If you want speed-up the process you can use a dnf-local package cache on your
build host. 

## Building the Container (simple way)
If you wish to build the container in a simple manner, you can use the provided
pypyr pipeline:

```bash
pypyr ./build.yaml
```
 The pypyr-pipeline can optional controlled by key=value parameters. In the
 example above you can see, there is no mode-parameter submitted. This is
 not necessary. The default behavior is, that the pipeline only build the
 container.

 ```bash

pypyr ./build.yaml <para1=value> <ypara2=value> ...
pypyr ./build.yaml mode=build                          # defines that
                                                        # pipeline should
                                                        # build the conteiner

| parameter   | values      | default  | description                         |
+-------------+-------------+----------+-------------------------------------+
| mode        | build       | build    | controls who the pipeline works.    |
|             | deploy      |          | supported modes are:                |
|             | push        |          |   - build: builds the container     |
|             |             |          |   - deploy: deploy on local host    |
|             |             |          |             with podman             |
|             |             |          |   - push: push the fresh generated  |
|             |             |          |           to a artefact-registry    |
+-------------+-------------+----------+-------------------------------------+
| author      | string      | none     | Author name of the image. If you    |
|             |             |          | modify the base creation script     |
|             |             |          | you should provide an author.       |
+-------------+-------------+----------+-------------------------------------+
| authormail  | string      | none     | email address of the author         |
+-------------+-------------+----------+-------------------------------------+
| pkg_cache   | path        | none     | optional pfad for rpm package cache |
+-------------+-------------+----------+-------------------------------------+

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
