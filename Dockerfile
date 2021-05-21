FROM node:current-alpine3.11

RUN mkdir /app

COPY ./app/hooli /app

EXPOSE 8080

CMD node /app/app.js