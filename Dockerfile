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

RUN npm install -g elm-test
RUN npm install -g elm-format
RUN npm install -g elm-review

# Expose the morphir-elm develop port
EXPOSE 3000

# Setup User environment
USER $USER

RUN mkdir -p /home/$USER/workspace
RUN mkdir -p /tmp/setup 
RUN mkdir -p /home/$USER/morphir/example 
COPY --chown=$USER:$USER_GROUP ./setup /tmp/setup
COPY --chown=$USER:$USER_GROUP ./example /home/$USER/morphir/example

WORKDIR /tmp/setup
RUN rm elm.json
RUN echo "y" | elm init 
RUN echo "y" | elm install "finos/morphir-elm" 
RUN echo "y" | elm-test install "elm-explorations/test"
RUN elm-test

WORKDIR /home/$USER/workspace


# ENTRYPOINT [ "morphir-elm" ]
ENTRYPOINT ["/bin/bash"]