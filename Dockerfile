FROM node:16 as node_base

ARG USER_GROUP=5000
ARG USER=git

RUN \
    groupadd -g $USER_GROUP $USER && \
    useradd -u $USER_GROUP -g $USER $USER -m && \
    chown -R $USER:$USER /home/$USER

FROM node_base as morphir_elm

RUN npm install -g morphir-elm

# Expose the morphir-elm develop port
EXPOSE 3000

# Setup User environment
USER $USER

RUN mkdir -p /home/$USER/workspace
WORKDIR /home/$USER/workspace

ENTRYPOINT [ "morphir-elm" ]
# ENTRYPOINT []