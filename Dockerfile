FROM node:16-alpine as node_base

# [Option] Install zsh
ARG INSTALL_ZSH="true"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=5000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/
RUN apk update && ash /tmp/library-scripts/common-alpine.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" \
    && rm -rf /tmp/library-scripts

RUN apk update && \
    apk upgrade && \
    apk add --no-cache bash build-base curl file git gzip sudo && \
    apk add --no-cache nushell --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing/ --repository=https://dl-cdn.alpinelinux.org/alpine/edge/main && \
    rm -rf /var/lib/apt/lists/*    


RUN apk add openjdk11

FROM node_base as morphir_elm

ARG MILL_VERSION=0.10.7

RUN npm install -g morphir-elm

FROM morphir_elm as elm_tooling

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz && gunzip elm.gz && chmod +x elm && mv elm /usr/local/bin/

RUN npm install -g elm-test
RUN npm install -g elm-format
RUN npm install -g elm-review
RUN npm install -g elm-live

# Add elm-test-rs
RUN curl -L -o elm-test-rs.tar.gz https://github.com/mpizenberg/elm-test-rs/releases/download/v2.0.1/elm-test-rs_linux.tar.gz && \
    tar -xzvf elm-test-rs.tar.gz && chmod +x elm-test-rs && mv elm-test-rs /usr/local/bin/   

# Add mill
RUN sh -c "curl -L https://github.com/com-lihaoyi/mill/releases/download/${MILL_VERSION}/${MILL_VERSION} > /usr/local/bin/mill && chmod +x /usr/local/bin/mill" && mill version

# Expose the morphir-elm develop port
EXPOSE 3000

# Setup User environment
USER $USERNAME

RUN mkdir -p /home/$USERNAME/workspace
RUN mkdir -p /tmp/setup 
RUN mkdir -p /home/$USERNAME/morphir/example 
COPY --chown=$USERNAME:$USER_GID ./setup /tmp/setup
COPY --chown=$USERNAME:$USER_GID ./example /home/$USERNAME/morphir/example


WORKDIR /tmp/setup
RUN rm elm.json
RUN echo "y" | elm init 
RUN echo "y" | elm install "finos/morphir-elm" 
RUN echo "y" | elm-test install "elm-explorations/test"
RUN elm-test

#ADD the morphir examples repo
WORKDIR /home/$USERNAME/morphir/
RUN git clone https://github.com/finos/morphir-examples.git 
WORKDIR /home/$USERNAME/morphir/morphir-examples
RUN elm-test


WORKDIR /home/$USERNAME/workspace

EXPOSE 8000

COPY --chown=$USERNAME:$USER_GID user/.config /home/$USERNAME/.config/

CMD ["nu"]