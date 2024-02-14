#FROM bitnami/git:latest AS build_node_modules_source_code
#LABEL maintainer="janwiebe@janwiebe.eu"

# Clone the wg-easy repository
#WORKDIR /
#RUN git clone https://github.com/wg-easy/wg-easy

FROM docker.io/library/node:18-alpine AS build_node_modules
LABEL maintainer="janwiebe@janwiebe.eu"

# Copy Web UI
#COPY --from=build_node_modules_source_code /wg-easy/src/ /app/
# Install Curl
RUN apk update && apk add git curl
WORKDIR /
RUN git clone https://github.com/wg-easy/wg-easy.git
WORKDIR /wg-easy/src
RUN npm install
RUN npm ci --production

FROM ubuntu:22.04
LABEL maintainer="janwiebe@janwiebe.eu"

# Install necessary packages
RUN apt-get update
RUN apt-get install -y nodejs npm wget

COPY --from=build_node_modules /wg-easy/src /app
WORKDIR /app
RUN npm install

# Move node_modules one directory up
RUN mv /app/node_modules /node_modules

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    iproute2 \
    wireguard \
    wireguard-tools \
    dumb-init \
    iptables && \
    rm -rf /var/lib/apt/lists/*

# Enable this to run `npm run serve`
RUN npm i -g nodemon

# Expose Ports
EXPOSE 51820/udp
EXPOSE 51821/tcp

# Set Environment
ENV DEBUG=Server,WireGuard

# Run Web UI
WORKDIR /app
CMD ["/usr/bin/dumb-init", "node", "server.js"]
