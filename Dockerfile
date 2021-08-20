FROM node AS app

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install -g npm@7.20.6

COPY . .
RUN node seeds/seed.js
EXPOSE 3000

CMD ["node", "seeds/seed.js"]
CMD ["node", "app.js"]


# Let's build a multi-stage production ready image

FROM node:alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install -g npm@7.20.6

COPY --from=app /usr/src/app /usr/src/app

EXPOSE 3000

CMD ["node", "seeds/seed.js"]
CMD ["node", "app.js"]