FROM node:25.5.0-alpine3.22 AS fnl_base_image
ENV PORT 4030
ENV NODE_ENV production
WORKDIR /usr/src/app

# Upgrade OpenSSL, musl, and zlib to patched versions (POPSCI-532)
# - libcrypto3/libssl3: CVE-2026-2673, CVE-2026-28387 through CVE-2026-28390, CVE-2026-31789,
#   CVE-2026-31790, CVE-2026-34182, CVE-2026-34183, CVE-2026-42764, CVE-2026-45445, CVE-2026-45447
# - musl/musl-utils: CVE-2026-6042, CVE-2026-40200
# - zlib: CVE-2026-22184, CVE-2026-27171
# Remove Node.js OpenSSL headers to avoid false positive detection (CVE-2025-15467)
RUN apk update && \
    apk upgrade --no-cache libcrypto3 libssl3 musl musl-utils zlib && \
    apk del gnupg 2>/dev/null || true && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/local/include/node/openssl

RUN npm install -g npm@11.7.0
RUN rm -rf /usr/local/lib/node_modules/npm/node_modules/cross-spawn
COPY package*.json ./
#RUN npm ci --only=production
RUN npm install --omit=dev \
  && npm cache clean --force \
  && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx
COPY  --chown=node:node . .
EXPOSE 4030
CMD [ "node", "./bin/www" ]