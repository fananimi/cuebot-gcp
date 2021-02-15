# -----------------
# BUILD
# -----------------
FROM gradle:6.0.1-jdk11 as build

USER gradle

# First line after FROM should be unique to avoid --cache-from weirdness.
RUN echo "Cuebot build stage"

COPY --chown=gradle:gradle ./OpenCue/cuebot /home/gradle/cuebot/
COPY --chown=gradle:gradle ./OpenCue/proto /home/gradle/proto/

WORKDIR /home/gradle/cuebot

RUN gradle build --stacktrace

COPY ./OpenCue/VERSION.in VERSIO[N] ./
RUN test -e VERSION || echo "$(cat VERSION.in)-custom" | tee VERSION
RUN mv ./build/libs/cuebot.jar ./build/libs/cuebot-$(cat ./VERSION)-all.jar

# --------------------------------------------------------------------
# RUN
# --------------------------------------------------------------------
FROM ubuntu:18.04

RUN echo "Starting build cuebot server for Google Cloud Platform"

# --------------------------------------------------------------------
# Global Environment
# --------------------------------------------------------------------
# Update YOUR_BUCKET_NAME with the name of your bucket in the following line:
# This variable is referenced in startup.sh
ENV GCS_FUSE_BUCKET YOUR_BUCKET_NAME

# This is the GCS bucket mount point on your Render Host. Referenced in startup.sh.sh
ENV GCS_FUSE_MOUNT /shots

# --------------------------------------------------------------------
# Install some dependencies
# --------------------------------------------------------------------
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install \
        curl \
        gnupg2 \
        openjdk-11-jre \
        --no-install-recommends \
        -y

# --------------------------------------------------------------------
# Install gcs-fuse and google cloud SDK
# --------------------------------------------------------------------
RUN echo "deb http://packages.cloud.google.com/apt gcsfuse-bionic main" | tee /etc/apt/sources.list.d/gcsfuse.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && \
    apt-get install gcsfuse -y
RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-bionic main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN apt-get update && apt-get install google-cloud-sdk -y

# --------------------------------------------------------------------
# Removing cache
# --------------------------------------------------------------------
RUN apt-get clean && \
    apt-get autoclean  && \
    apt-get remove  && \
    apt-get autoremove  && \
    rm -rf /var/lib/apt/lists/*

# --------------------------------------------------------------------
# Build cuebot
# --------------------------------------------------------------------
# First line after FROM should be unique to avoid --cache-from weirdness.
RUN echo "Cuebot runtime stage"

ARG CUEBOT_GRPC_CUE_PORT=8443
ARG CUEBOT_GRPC_RQD_PORT=8444

WORKDIR /opt/opencue

COPY --from=build /home/gradle/cuebot/build/libs/cuebot-*-all.jar ./
RUN ln -s $(ls ./cuebot-*-all.jar) ./cuebot-latest.jar

# TODO(bcipriano) Implement a new GRPC-based health check.
# https://github.com/imageworks/OpenCue/issues/73
# HEALTHCHECK --start-period=30s --timeout=5s CMD python check_ice.py localhost CueStatic 9019

VOLUME ["/opt/opencue/logs"]

ENV grpc_cue_port ${CUEBOT_GRPC_CUE_PORT}
ENV grpc_rqd_port ${CUEBOT_GRPC_RQD_PORT}

EXPOSE $grpc_cue_port

COPY startup.sh ./startup.sh
# NOTE: This shell out is needed to avoid RQD getting PID 0 which leads to leaking child processes.
ENTRYPOINT ["./startup.sh"]

