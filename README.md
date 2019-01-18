# Container for reposync

[![Docker Repository on Quay](https://quay.io/repository/tinsjourney/reposync/status "Docker Repository on Quay")](https://quay.io/repository/tinsjourney/reposync)

This script will create an OCI image using buildah, which can be run using podman

## Build image
To build the image just run the Podmanfile script
```
$ ./Podmanfile
0c0c5ba15ce235afe416fd476b652b8c837f131d818b2805fad59e570e5a699e
Getting image source signatures
Skipping fetch of repeat blob sha256:56a763045c4544c21c458f3cd948a46384e4b12f9deacd1aede445af598f6d84
Skipping fetch of repeat blob sha256:ab9227d97750aff30bf47631468e9b69dddcdd4af6a853233d6288d05770fcf8
Copying blob sha256:893bc91c31ac1888697aade20c672a69d37839fa1e894b19217e325bda6922e7
 2.42 KiB / 2.42 KiB [======================================================] 0s
Copying config sha256:5529970130b40412fab8da6820693c9a8853191b31d85ed76dbea10f75f692f0
 3.37 KiB / 3.37 KiB [======================================================] 0s
Writing manifest to image destination
Storing signatures
5529970130b40412fab8da6820693c9a8853191b31d85ed76dbea10f75f692f0
$ podman images
REPOSITORY                         TAG        IMAGE ID       CREATED             SIZE
localhost/reposync                 20190118   5529970130b4   31 minutes ago      214 MB
```

## Quick start

**NOTE**: The podman command provided in this quick start is given as an example and parameters should be adjusted to your need.

Launch the reposync container with the following command:
```
podman run -dt \
    --name=reposync \
    -v $HOME/myconfig.env:/usr/local/etc/config.env:ro,Z \
    -v $HOME/repo:/var/www/html:rw,Z \
    quay.io/tinsjourney/reposync
```

Where:
  - `config.env`: This is the configuration file with RHSM credentials and repository list as explain in [rh_reposync.md](https://github.com/tinsjourney/misc/blob/master/rh_reposync.md).
  - `/repo`: This is where the repositories will be mirrored.
  - `$HOME`: This location contains files from your host that need to be accessible by the application.

# Usage

```
podman run [-dt] \
    --name=reposync \
    [-e <VARIABLE_NAME>=<VALUE>]... \
    [-v <CONFIG_FILE>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    [-v <REPO_DIR>:<CONTAINER_DIR>[:PERMISSIONS]]... \
    quay.io/tinsjourney/reposync
```
| Parameter | Description |
|-----------|-------------|
| -d        | Run the container in background.  If not set, the container runs in foreground. |
| -e        | Pass an environment variable to the container.  See the [Environment Variables](#environment-variables) section for more details. |
| -v        | Set a volume mapping (allows to share a folder/file between the host and the container).  See the [Data Volumes](#data-volumes) section for more details. |

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`NEWEST_ONLY`| When set to false, will download all versions of packages available in the original repository.  | `true` |
|`SYNC_DATE`| When updating and existing mirror, set this variable to match the previous synchronization directory. | `date +%Y%m%d`|
|`CONFIG`| This is where the reposync script in the container will look for the config file. Set this variable is you mapped the config.env file in an other directory. | `/usr/local/etc/config.env` |

### Data Volumes

The following table describes data volumes used by the container.  The mappings
are set via the `-v` parameter.  Each mapping is specified with the following
format: `<HOST_DIR>:<CONTAINER_DIR>[:PERMISSIONS]`.

| Container path  | Permissions | Description |
|-----------------|-------------|-------------|
|`/usr/local/etc/config.env`| ro,Z | This is where the config.env file is read by the reposync script. If you change it, use the CONFIG environment variable.  |
|`/var/www/html`| rw,Z | This location contains files from your host that need to be accessible by the application. |

### Changing Parameters of a Running Container

As seen, environment variables and volume mappings are specified while creating the container.

The following steps describe the method used to add, remove or update parameter(s) of an existing container.  The generic idea is to destroy and re-create the container:

  1. Stop the container (if it is running):
```
podman stop reposync
```
  2. Remove the container:
```
podman rm reposync
```
  3. Create/start the container using the `podman run` command, by adjusting
     parameters as needed.
