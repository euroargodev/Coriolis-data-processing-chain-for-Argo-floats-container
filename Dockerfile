FROM gitlab-registry.ifremer.fr/ifremer-commons/docker/images/ubuntu:22.04 AS development

RUN \
    apt-get -y update && \
    apt-get -y install wget unzip && \
    apt-get clean && \
    mkdir -p /tmp/config

WORKDIR /tmp

COPY decArgo_soft/exec/run_decode_argo_2_nc_rt.sh .
COPY decArgo_soft/exec/decode_argo_2_nc_rt .
COPY decArgo_soft/config/configuration_sample_files_docker/*.json ./config
COPY decArgo_soft/config/_configParamNames ./config/_configParamNames
COPY decArgo_soft/config/_techParamNames ./config/_techParamNames

FROM gitlab-registry.ifremer.fr/ifremer-commons/docker/images/ubuntu:22.04 AS runtime

# configurable arguments
ARG RUN_FILE=run_decode_argo_2_nc_rt.sh
ARG GROUPID=9999
ARG DATA_DIR=/mnt/data
ARG RUNTIME_DIR=/mnt/runtime
ARG REF_DIR=/mnt/ref
ENV APP_DIR=/app

# environment variables
ENV DATA_HOME=${DATA_DIR}
ENV RUNTIME_HOME=${RUNTIME_DIR}
ENV REF_HOME=${REF_DIR}
ENV APP_HOME=${APP_DIR}
ENV APP_RUN_FILE=${RUN_FILE}
ENV MCR_CACHE_ROOT=/tmp/matlab/cache

# prepare os environment
RUN \
    apt-get -y update && \
    echo "===== MISE A JOUR OS =====" && \
    apt-get -y upgrade && \
    echo "===== ADD TOOLS LIBRARIES =====" && \
    apt-get -y install wget && \
    echo "===== ADD MATLAB REQUIRED LIBRARIES =====" && \
    apt-get -y install libxtst6 libxt6 && \
    echo "===== CREATION GROUPE UNIX gbatch (gid = ${GROUPID}) =====" && \
    groupadd --gid ${GROUPID} gbatch && \
    echo "===== GENERAL SYSTEM CLEANUP =====" && \
    apt-get purge -y manpages manpages-dev && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    apt-get clean -y && \
    rm -rf /usr/share/locale/* && \
    rm -rf /var/cache/debconf/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/doc/*

WORKDIR ${APP_DIR}

COPY --from=development /tmp/ .
COPY entrypoint.sh .

# adjust rights
RUN \
    chown -R root:gbatch ${APP_DIR} /mnt && \
    chmod -R 770 ${APP_DIR} /mnt

ENTRYPOINT ["/app/entrypoint.sh"]

FROM runtime AS python-runtime

WORKDIR /app

COPY decArgo_api .

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    python3 -m pip install --upgrade pip && \
    rm -rf /var/lib/apt/lists/* && \ 
    pip install "poetry~=1.8.0" && \
    poetry config virtualenvs.create false && \
    poetry install

COPY --from=development /tmp .
# TODO : need to be remove after fix
COPY decArgo_soft/exec/run_decode_argo_2_nc_rt.tmp.sh run_decode_argo_2_nc_rt.sh   


# Second ticket, add the API layer:
# 1. Install the API package
# 2. Set up a Gunicorn entrypoint to replace the original script

# ENTRYPOINT ["/path/to/gunicorn"]
# CMD: ["your", "gunicorn", "args"]


# classique runtime image
# FROM runtime-base AS runtime

# ENTRYPOINT ["/app/entrypoint.sh"]

# Galaxy runtime image
# FROM runtime-base AS runtime-galaxy

# RUN \
#     apt-get -y update && \
#     echo "===== ADD TOOLS LIBRARIES =====" && \
#     apt-get -y install zip unzip

# COPY --chown=root:gbatch ./R2022b /mnt/runtime

# USER 1000:${GROUPID}