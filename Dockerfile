FROM node:16-alpine as node_base

RUN apk update && \
    apk add bash build-base curl file git gzip sudo && \
    apk add nushell --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main && \
    rm -rf /var/lib/apt/lists/*    

ARG USER_GROUP=developer
ARG USER=morphirdev

RUN \
    addgroup -S $USER_GROUP && \
    adduser -S $USER -G $USER_GROUP && \
    chown -R $USER:$USER_GROUP /home/$USER

# RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" && \
#     PATH=$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH    

# RUN brew update && brew doctor

FROM node_base as morphir_elm

RUN npm install -g morphir-elm

FROM morphir_elm as elm_tooling

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz && gunzip elm.gz && chmod +x elm && mv elm /usr/local/bin/

RUN npm install -g elm-test
RUN npm install -g elm-format
RUN npm install -g elm-review
RUN npm install -g elm-live

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

EXPOSE 8000

# ENTRYPOINT [ "morphir-elm" ]
CMD ["nu"]