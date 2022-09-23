FROM node:16 as node_base

ARG USER_GROUP=5000
ARG USER=git

RUN \
    groupadd -g $USER_GROUP $USER && \
    useradd -u $USER_GROUP -g $USER $USER -m && \
    chown -R $USER:$USER /home/$USER

FROM node_base as morphir_elm

RUN npm install -g morphir-elm

FROM morphir_elm as elm_tooling

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz && gunzip elm.gz && chmod +x elm && mv elm /usr/local/bin/

# Expose the morphir-elm develop port
EXPOSE 3000

# Setup User environment
USER $USER

RUN mkdir -p /home/$USER/workspace
RUN mkdir -p /tmp/setup 
COPY --chown=$USER:$USER_GROUP ./setup /tmp/setup

WORKDIR /tmp/setup
RUN echo "y" | elm install "finos/morphir-elm" 

WORKDIR /home/$USER/workspace


# ENTRYPOINT [ "morphir-elm" ]
ENTRYPOINT ["/bin/bash"]