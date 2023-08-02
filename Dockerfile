FROM node:latest AS deps
WORKDIR /opt/app
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm
RUN pnpm install --frozen-lockfile
FROM node:latest AS builder
ENV NODE_ENV=production
WORKDIR /opt/app
RUN npm install -g pnpm
COPY . .
COPY --from=deps /opt/app/node_modules ./node_modules
RUN pnpm build
FROM gcr.io/distroless/nodejs20-debian11 AS runner
ARG X_TAG
WORKDIR /opt/app
ENV NODE_ENV=production
COPY --from=builder /opt/app/next.config.mjs ./
COPY --from=builder /opt/app/public ./public
COPY --from=builder /opt/app/.next ./.next
COPY --from=builder /opt/app/node_modules ./node_modules
ENV HOST=0.0.0.0
ENV PORT=3000
CMD ["./node_modules/next/dist/bin/next", "start"]
