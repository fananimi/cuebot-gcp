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
-e DB_HOST=$DB_HOST \
-e DB_PORT=$DB_PORT \
-e DB_NAME=$DB_NAME \
-e DB_USER=$DB_USER \
-e DB_PASS=$DB_PASS \
-dit \
--name cuebot \
--network host \
--privileged \
-p 8080:8080 \
-p 8443:8443 \
<IMAGE_ID>
~~~~

Figure 1 - OpenCue Architecture
--------------------------------

![](https://www.opencue.io/docs/images/opencue_architecture.svg)
