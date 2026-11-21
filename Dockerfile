FROM node:24-alpine

ENV NODE_ENV=production
WORKDIR /app

RUN apk upgrade --no-cache

COPY --chown=node:node package*.json ./
RUN npm ci --omit=dev \
  && npm cache clean --force \
  && rm -rf /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/corepack /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack

COPY --chown=node:node src ./src
COPY --chown=node:node database ./database
COPY --chown=node:node scripts ./scripts

USER node
EXPOSE 3000

HEALTHCHECK --interval=15s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:3000/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "src/server.js"]
