FROM node:lts-slim AS base
WORKDIR /app
ENV NODE_ENV production

FROM base AS deps
COPY package.json package-lock.json ./
RUN npm ci --omit=optional

FROM deps AS builder
ENV NODE_ENV dev
COPY . .
RUN npm ci
RUN npm run build

FROM base AS runner
ENV NEXT_TELEMETRY_DISABLED 1
RUN useradd -m -U nextjs

COPY --from=deps /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY package.json .
RUN chown -R nextjs:nextjs /app

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"
CMD ["npm", "run", "start"]
