# flexget container

This is a simple buildah script for building flexget container. If you
whish a simple build pipeline you should install [pypr](https://pypyr.io)
on your container host and invoce the build :

```bash
pip3 install pypyr
pypyr ./build.yaml
```

The pypyr-pipline has various confíguration options, which can assigned optional
during invocation. The parameter are key=value strings.

| Option | Value(s) | Description |
|--------|----------|-------------|
| mode   | build/deploy/push | mode that describes how the pipeline shoud executed |
| baseimage | latest / version no | Which fedora base image should be used |
| registry | URL | registry where the artefact should be pushed |
| author | str | Author name |
| authormail | str | Author email address | 

## Artefact push to registry

By default it's possible to push without additional configuration to [ghcr.io](https://ghcr.io).
The pipleline tries to obtain a github PAT: for this it's necessary that a
username and password is submitted.