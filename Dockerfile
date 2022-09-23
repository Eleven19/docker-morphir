From node:16 as node_base

FROM node_base as morphir_elm

RUN npm install -g morphir-elm

# Expose the morphir-elm develop port
EXPOSE 3000
