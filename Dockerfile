ARG RUNTIME_BASE_IMAGE=ubuntu:focal
ARG RUNTIME_USER=keyspub
ARG RUNTIME_UID=1000
ARG RUNTIME_GID=1000


# ============================8< root stage >8============================

FROM ${RUNTIME_BASE_IMAGE} AS root
ARG RUNTIME_BASE_IMAGE
ARG RUNTIME_USER
ARG RUNTIME_UID
ARG RUNTIME_GID

LABEL maintainer="Phil Pennock <noc+keys.pub@pennock-tech.com>"
LABEL org.opencontainers.image.vendor="Pennock Tech, LLC"
LABEL org.opencontainers.image.title="keys.pub"
LABEL org.opencontainers.image.description="https://keys.pub tooling"
LABEL tech.pennock.baseimage="${RUNTIME_BASE_IMAGE}"

LABEL com.pennock-tech.runtime.username="${RUNTIME_USER}"
LABEL com.pennock-tech.runtime.uid="${RUNTIME_UID}"
LABEL com.pennock-tech.runtime.gid="${RUNTIME_GID}"

# We have to do one update, to find ca-certificates, to install from an https
# apt repo, as COPY'd in.
RUN apt-get -y update && apt-get install -y ca-certificates

COPY keys.list /etc/apt/sources.list.d/keys.list
COPY apt-repo-signing-key.gpg /etc/apt/trusted.gpg.d/

RUN apt-get -y update && apt-get upgrade -y
RUN apt-get install -y curl ca-certificates zsh less vim-tiny tree jq silversearcher-ag
RUN apt-get install -y keys
RUN apt-get install -f -y

RUN true \
        && groupadd -g ${RUNTIME_GID} ${RUNTIME_USER} \
        && useradd --create-home -g ${RUNTIME_USER} -u ${RUNTIME_UID} ${RUNTIME_USER} \
        && mkdir -pv -m 0700 /run/user/${RUNTIME_UID} && chown ${RUNTIME_USER}:${RUNTIME_USER} /run/user/${RUNTIME_UID} \
        && rm -r /var/lib/apt/lists/*

VOLUME /home/${RUNTIME_USER}

# ===========================8< final stage >8============================

FROM root
ARG RUNTIME_USER
ARG RUNTIME_UID

USER ${RUNTIME_USER}
WORKDIR /home/${RUNTIME_USER}

ENV XDG_RUNTIME_DIR /run/user/${RUNTIME_UID}

CMD ["bash"]
