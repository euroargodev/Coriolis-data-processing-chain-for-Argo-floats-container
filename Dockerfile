FROM gitlab-registry.ifremer.fr/ifremer-commons/docker/images/ubuntu:22.04 AS prepare

RUN \
    apt-get -y update && \
    apt-get -y install wget unzip && \
    mkdir -p /tmp/config

ARG HEADER_TOKEN
ARG APP_VERSION
ARG APP_FILENAME

WORKDIR /tmp

COPY decArgo_soft/exec/run_decode_argo_2_nc_rt.sh .
COPY decArgo_soft/exec/decode_argo_2_nc_rt .
COPY decArgo_soft/config/configuration_sample_files_docker/_argo_decoder_conf_ir_sbd.json config/
COPY decArgo_soft/config/configuration_sample_files_docker/_argo_decoder_conf_ir_sbd_rem.json config/
COPY decArgo_soft/config/_configParamNames config/
COPY decArgo_soft/config/_techParamNames config/

FROM gitlab-registry.ifremer.fr/ifremer-commons/docker/images/ubuntu:22.04 AS runtime

# confifurable arguments
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

COPY --from=prepare /tmp/ .
COPY entrypoint.sh .

# adjust rights
RUN \
    chown -R root:gbatch ${APP_DIR} /mnt /tmp && \
    find . -type f -exec chmod ug+x {} \;

ENTRYPOINT ["/app/entrypoint.sh"]
