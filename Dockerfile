FROM node:22-bookworm AS build
WORKDIR /app
COPY app/server.js ./src/server.js
RUN mkdir -p dist && cp src/server.js dist/server.js

FROM node:22-bookworm
WORKDIR /workspace
COPY . .
USER root
EXPOSE 3000
CMD ["node", "app/server.js"]
