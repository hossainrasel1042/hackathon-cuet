ARG NODE_VERSION=lts-alpine
ARG BUILD_VERSION=1.0
ARG BUILD_USER_NAME=hossainrasel
ARG BUILD_USER_EMAIL=hossain.rasel.1042@gmail.com
ARG MODIFIED_BY=Redwan

# --- BUILDER ---
FROM node:${NODE_VERSION} AS builder
WORKDIR /app
COPY package*.json ./
COPY tsconfig*.json ./
#need python and build tools to compile some dependencies
RUN apk add --no-cache python3 make g++ \
    && npm install \
    && apk del python3 make g++

COPY . .
RUN npm run build

# --- RUNNER ---
FROM node:${NODE_VERSION} AS runner

ARG NODE_VERSION=lts-alpine
ARG BUILD_VERSION=1.0
ARG BUILD_USER_NAME=hossainrasel
ARG BUILD_USER_EMAIL=hossain.rasel.1042@gmail.com
ARG MODIFIED_BY=Redwan
ARG BUILD_DATE
ARG VCS_REF

LABEL version=${BUILD_VERSION} \
      BUILD_USER_NAME=${BUILD_USER_NAME} \
      BUILD_USER_EMAIL=${BUILD_USER_EMAIL} \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.revision=${VCS_REF} \
      org.opencontainers.image.authors="${BUILD_USER_NAME}" \
      org.opencontainers.image.modified_by="${MODIFIED_BY}"

WORKDIR /app
RUN apk add --no-cache curl tini
RUN addgroup -g 1001 -S ProductionBackend && \
    adduser -S ProductionBackend -u 1001 ProductionBackend

COPY package*.json ./
RUN npm install --only=production --no-audit
COPY --from=builder --chown=ProductionBackend:ProductionBackend /app/dist ./dist
USER ProductionBackend
EXPOSE 3847
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
  CMD curl -f http://backend:3847/api/health || exit 1
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "dist/index.js"]