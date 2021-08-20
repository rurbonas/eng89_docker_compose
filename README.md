# Docker Compose - NodeJS with MongoDB

Compose file maps the `docker run` command(s) into a file and it is so convenient as we do not have to type all the parameters to pass to the `docker run` command. We can declaratively do that in the Compose file.

Note that unlike the `docker run` command, with Docker compose we don't have to define any network. That's because the Docker compose takes care of creating a common network between containers. It creates a network named as `"working-directory__default"`. In our case, it's `node-mongodb-docker-compose_default`. We can see it from the message when we run `docker-compose`.


### docker-compose.yml:
```YAML
version: '3.8'

services:
  # start the db image and map to port 27017
  db:
    image: mongo
    restart: always
    ports: [27017:27017]

  web:
    # start up the web app image and map to localhost
    build: .
    restart: always
    ports: [80:3000]
    # set variable for db port
    environment:
      - DB_HOST=mongodb://db:27017/posts
    depends_on:
      - db
```

### Dockerfile:
```
FROM node AS app

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install -g npm@7.20.6

COPY . .

EXPOSE 3000
CMD ["cd", "seeds/seed.js"]
CMD ["node", "app.js"]


# Let's build a multi-stage production ready image

FROM node:alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install -g npm@7.20.6

COPY --from=app /usr/src/app /usr/src/app

EXPOSE 3000

RUN node seeds/seed.js
CMD ["cd", "seeds/seed.js"]
CMD ["node", "app.js"]
```

1. In the Dockerfile, we are creating a working directory, WORKDIR /app to instruct Docker to use this path as the default location for all subsequent commands. This way we do not have to type out full file paths but can use relative paths based on the working directory.
2. Before we run `npm install`, we need to get our package.json and package-lock.json files into our images using `COPY` command. We copy the package.json and package-lock.json files into our working directory /app.
3. Once we have our package.json files inside the image, we can use the `RUN` command to execute the command `npm install`. This works exactly the same as if we were running `npm install` locally on our machine, but this time these Node modules will be installed into the node_modules directory inside our image.
4. After `RUN npm install`, we have an image that is based on node version 12.18.1 and we have installed our dependencies.
5. `COPY . .` adds our source code into the image. It takes all the files located in the current directory and copies them into the image.
6. Now, we want to tell Docker what command we want to run when our image is run inside of a container via `CMD [ "npm", "start" ]`.

To start:
- `docker-compose up -d`
- check localhost

## App Description

This app is intended for use with the Sparta Global Devops Stream as a sample app. You can clone the repo and use it as is but no changes will be accepted on this branch. 

To use the repo within your course you should fork it.

The app is a node app with three pages.

### Homepage

``localhost:3000``

Displays a simple homepage displaying a Sparta logo and message. This page should return a 200 response.

### Blog

``localhost:3000/posts``

This page displays a logo and 100 randomly generated blog posts. The posts are generated during the seeding step.

This page and the seeding is only accessible when a database is available and the DB_HOST environment variable has been set with it's location.

### A fibonacci number generator

``localhost:3000/fibonacci/{index}``

This page has be implemented poorly on purpose to produce a slow running function. This can be used for performance testing and crash recovery testing.

The higher the fibonacci number requested the longer the request will take. A very large number can crash or block the process.


### Hackable code

``localhost:3000/hack/{code}``

There is a commented route that opens a serious security vulnerability. This should only be enabled when looking at user security and then disabled immediately afterwards

## Usage

Clone the app

```
npm install
npm start
```

You can then access the app on port 3000 at one of the urls given above.

## Tests

There is a basic test framework available that uses the Mocha/Chai framework

```
npm test
```

The test for posts will fail ( as expected ) if the database has not been correctly setup.




