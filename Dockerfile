# Runtime stage - minimal alpine with only node (no npm!)
FROM alpine:3.23
ENV PORT=8082
ENV NODE_ENV=production
WORKDIR /usr/src/app

# Install runtime dependencies and upgrade packages
RUN apk add --no-cache libstdc++ libgcc && \
    apk upgrade --no-cache libcrypto3 libssl3

# Copy node binary and libraries from builder (without npm)
COPY --from=builder /usr/local/bin/node /usr/local/bin/
COPY --from=builder /usr/lib/libgcc* /usr/lib/
COPY --from=builder /usr/lib/libstdc* /usr/lib/

# Create node user
RUN addgroup -g 1000 node && \
    adduser -u 1000 -G node -s /bin/sh -D node

# Copy application dependencies and code
COPY --from=builder --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --chown=node:node . .

EXPOSE 8082
USER node
CMD ["node", "./bin/www"]