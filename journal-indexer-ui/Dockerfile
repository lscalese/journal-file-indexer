FROM node:18.10-alpine AS builder

USER root
WORKDIR /app
COPY /journal-indexer-ui/ .

RUN npm install
RUN npm run build

CMD ["npm", "start", "--", "--host", "0.0.0.0", "--poll", "500"]