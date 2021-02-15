#!/usr/bin/env bash
mkdir -p $GCS_FUSE_MOUNT
gcsfuse --implicit-dirs -o rw,allow_other --uid 1000 --gid 1000 --dir-mode 777 --file-mode 777 $GCS_FUSE_BUCKET $GCS_FUSE_MOUNT

java -jar /opt/opencue/cuebot-latest.jar \
--datasource.cue-data-source.jdbc-url=jdbc:postgresql://$DB_HOST/$DB_NAME \
--datasource.cue-data-source.username=$DB_USER \
--datasource.cue-data-source.password=$DB_PASS \
--log.frame-log-root="${CUE_FS_ROOT}/logs"
