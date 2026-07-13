FROM node:24-alpine3.23 AS fnl_base_image

ENV PORT=4030
ENV NODE_ENV=production
WORKDIR /usr/src/app

# Upgrade base-image packages to patched versions (POPSCI-532)
# - libcrypto3/libssl3: CVE-2026-2673, CVE-2026-28387/28388/28389/28390, CVE-2026-31789/31790,
#                       CVE-2026-34182/34183, CVE-2026-42764, CVE-2026-45445/45447
# - musl/musl-utils: CVE-2026-6042, CVE-2026-40200
# - zlib: CVE-2026-22184, CVE-2026-27171
RUN apk update && \
    apk upgrade --no-cache libcrypto3 libssl3 musl musl-utils zlib && \
    rm -rf /var/cache/apk/*

# Copy package files first (better caching)
COPY package*.json ./

# Install dependencies, then remove npm (not needed at runtime)
RUN npm ci --omit=dev --ignore-scripts \
  && npm cache clean --force \
  && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx \
  && apk add --no-cache su-exec

# Copy application code
COPY --chown=node:node . .

EXPOSE 4030

COPY conf/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "node", "./bin/www" ]
