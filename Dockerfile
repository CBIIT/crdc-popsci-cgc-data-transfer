FROM node:24-alpine3.23 AS fnl_base_image

ENV PORT=4030
ENV NODE_ENV=production
WORKDIR /usr/src/app

# Copy package files first (better caching)
COPY package*.json ./

# Install dependencies, then remove npm (not needed at runtime)
RUN npm ci --omit=dev --ignore-scripts \
  && npm cache clean --force \
  && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx \
  && apk add --no-cache --upgrade \
  musl=1.2.5-r24 \
  musl-utils=1.2.5-r24 \
  libcrypto3 \
  libssl3 \
  zlib=1.4-r0 \
  su-exec

# Copy application code
COPY --chown=node:node . .

EXPOSE 4030

COPY conf/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "node", "./bin/www" ]
