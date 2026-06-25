FROM node:22.18-alpine3.22 AS fnl_base_image
ENV PORT 4030
ENV NODE_ENV production
WORKDIR /usr/src/app
COPY package*.json ./
#RUN npm ci --only=production
RUN npm install --legacy-peer-deps \
    && apk add --no-cache su-exec
COPY --chown=node:node . .
RUN mkdir -p /usr/src/app/logs && chown node:node /usr/src/app/logs
EXPOSE 4030
COPY conf/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "node", "./bin/www" ]
