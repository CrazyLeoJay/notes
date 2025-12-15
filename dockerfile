FROM node:25.2.1

RUN npm i docsify-cli -g

WORKDIR /app

EXPOSE 3000/tcp

ENTRYPOINT [ "docsify", "serve", "docs" ]
