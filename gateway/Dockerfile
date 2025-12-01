ARG NODE_VERSION=lts-alpine
ARG BUILD_VERSION=1.0
ARG BUILD_USER_NAME=hossainrasel
ARG BUILD_USER_EMAIL=hossain.rasel.1042@gmail.com
ARG MODIFIED_BY=Redwan
ARG BUILD_DATE
ARG VCS_REF

# --- BUILDER ---
FROM node:${NODE_VERSION} AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# --- RUNNER ---
FROM node:${NODE_VERSION} AS runner
LABEL version=${BUILD_VERSION} \
      BUILDE_USER_NAME=${BUILD_USER_NAME} \
      BUILD_USER_EMAIL=${BUILD_USER_EMAIL} \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.revision=${VCS_REF} \
      org.opencontainers.image.authors="${BUILD_USER_NAME}" \
      org.opencontainers.image.modified_by="${MODIFIED_BY}"

WORKDIR /app

RUN apk add --no-cache curl tini
RUN addgroup -g 1001 -S ProductionGateway && adduser -S ProductionGateway -u 1001 ProductionGateway
COPY package*.json ./
RUN npm install --only=production --no-audit
COPY --from=builder --chown=ProductionGateway:ProductionGateway /app/src ./src
USER ProductionGateway
EXPOSE 5921
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=5 \
  CMD curl -f http://localhost:5921/health || exit 1
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["node", "src/gateway.js"]