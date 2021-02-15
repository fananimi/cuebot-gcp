# cuebot-gcp

This project aims to provide cuebot container for Google Cloud Platform with Google Cloud Storage supports.

Usage
-----
~~~~
# make build
~~~~

Create Container
----------------
~~~~
# docker run \
-e GCS_FUSE_BUCKET=$GCS_FUSE_BUCKET \
-e GCS_FUSE_MOUNT=$GCS_FUSE_MOUNT \
-dit \
--name cuebot \
--privileged \
-p 8080:8080 \
-p 8443:8443 \
<IMAGE_ID> \
--datasource.cue-data-source.jdbc-url=jdbc:postgresql://$DB_HOST_IN_DOCKER/$DB_NAME \
--datasource.cue-data-source.username=$DB_USER \
--datasource.cue-data-source.password=$DB_PASS \
--log.frame-log-root="${CUE_FS_ROOT}/logs"
~~~~

Figure 1 - OpenCue Architecture
--------------------------------

![](https://www.opencue.io/docs/images/opencue_architecture.svg)
