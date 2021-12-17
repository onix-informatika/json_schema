####################
##   Dart Stage   ##
####################
FROM drydock-prod.workiva.net/workiva/dart2_base_image:1 as build

# Update image (required by aviary) and install tools
RUN apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y jq && \
    apt-get autoremove -y && \
    apt-get clean all

RUN wget https://github.com/mikefarah/yq/releases/download/3.4.1/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

# setup ssh
ARG GIT_SSH_KEY
ARG KNOWN_HOSTS_CONTENT

# Setting up ssh and ssh-agent for git-based dependencies
RUN mkdir /root/.ssh/ && \
  echo "$KNOWN_HOSTS_CONTENT" > "/root/.ssh/known_hosts" && \
  chmod 700 /root/.ssh/ && \
  umask 0077 && echo "$GIT_SSH_KEY" >/root/.ssh/id_rsa && \
  eval "$(ssh-agent -s)" && \
  ssh-add /root/.ssh/id_rsa

WORKDIR /build/

COPY pubspec.yaml /build/

COPY . /build/

# Build Environment Vars Required for wdesk app build, semver audit, and ddev's
# usage reporting.
ARG GIT_COMMIT
ARG GIT_TAG
ARG GIT_BRANCH
ARG GIT_MERGE_HEAD
ARG GIT_MERGE_BRANCH
ARG GIT_HEAD_REPO
ARG BUILD_ID

RUN timeout 5m pub get
RUN pub global activate --hosted-url https://pub.workiva.org semver_audit ^2.2.0
RUN pub global run semver_audit report --repo Workiva/workflow_forms

# Package up the artifacts
WORKDIR /build/