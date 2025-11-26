---
title: "Making the R Shiny Survey more Lightweight"
author: "Minna Heim & Matthias Bannert"
toc: false
draft: false
snippet: "Text...."
cover: ./shiny-survey.png
coverAlt: "R Shiny Frontend of an online survey"
publishDate: "2025-11-26"
category: "SELF-HOSTED, DevOps, Tutorial"
tags: [Survey, R, Shiny, Postgres, Docker, docker-compose, Alpine]
---


- if you want to run the app locally, before containerising, you should 

`library(shiny)` then cd to dir where you ui.R and server.R is located, then `runApp()` there.

but, cannot submit yet, will get an error. why? because db_container (i.e. our DB) does not exist yet! use this just for inspection of how front end looks like.


**Image Sizes**:

- `devxygmbh/r-alpine:4-3.21`: 138.3 MB
- `rocker/shiny`: 544.9 MB

With all the additional system dependencies installed, the final image amounts to

identify this, by running:

`docker build -t myimage` and then `docker images myimage`

- `base example`: 1.68GB
- `advanced example`: 789MB


**To Add to the Base Example**:

### `DOCKERFILE`

```Dockerfile
# TODO: be careful, arm and amd mismatch

# FROM --platform=linux/amd64 rocker/shiny
FROM devxygmbh/r-alpine:4-3.21

# Install system dependencies
# RUN apt-get update && apt-get install -y \
#     libpq-dev \
#     && rm -rf /var/lib/apt/lists/*

# TODO: do i need all those?
RUN apk add --no-cache \
      postgresql-client \
      postgresql-libs \
      postgresql-dev \
      g++ \
      make \
      libc6-compat \
      curl \
      # chat want's me to install these in case system libs are lacking to build shiny
      openssl-dev \
      zlib-dev \
      libuv-dev \


# Install R packages
# one at a time to see which ones act up / compile
RUN R -e "install.packages('DBI')"
RUN R -e "install.packages('RPostgres')"
RUN R -e "install.packages('shinythemes')"
RUN R -e "install.packages('shinyjs')"

WORKDIR /app
COPY app ./app

# Expose Shiny port
EXPOSE 3838

# Run Shiny in app mode (or use shiny-server if you install it)
CMD ["R", "--vanilla", "-e", "shiny::runApp('/srv/app/', host='0.0.0.0', port=3838)"]
```

main differences are:
- different image - lighter, before rocker/shiny
- more system dependencies, because of lighter image, now need to install postgresql
- specifying which workdir to use and copy to. (changed to putting all shiny things into the`/app` dir)


### `docker-compose.yaml`


```yaml
services:
   shiny:
      build:
         context: .
         dockerfile: DOCKERFILE
      container_name: fe_shiny
      # depends on:
      #    -  postgres
      restart: always
      ports:
         - "3838:3838"
      volumes:
         - "./app:/srv/app"
      command: ["R", "--vanilla", "-e", "shiny::runApp('/srv/app', host='0.0.0.0', port=3838)"]

   postgres:
      # a name, e.g.,  db_container is instrumental to be
      # called as host from the shiny app
      container_name: db_container
      image: postgres:15-alpine
      restart: always
      environment:
         - POSTGRES_USER=postgres
         - POSTGRES_PASSWORD=postgres # Don't use passwords like this in production
      # This port mapping is only necessary to connect from the host,
      # not to let containers talk to each other.
      # port-forwarding: from host port:to docker port -> mapping
      ports:
         - "1111:5432"
      # if container killed, then data is still stored in volume (locally)
      volumes:
         - "./pgdata:/var/lib/postgresql/data"
```

main differences are:

- changed app structure, here is the new app structure:

```text
.
├── app/
│   ├── ui.R
│   └── server.R
├── DOCKERFILE
├── docker-compose.yaml
├── blog.md
├── .gitignore    # ignores /pgdata
└── pgdata/       # postgres data volume (persistent data)
```

The rest of the content of the example is the same as in the initial blog post, i.e. the ui.R and server.R remain completely the same. 

Summary: all i wanted to show here is that in case you are more pressed for storage, and you want things to be more efficient, you can do so, by using a lighter image, and doing a little bit more of the configuation work. 

Running this example is the same as in the previous example. Once you have adjusted the following, all you need to do is:

`docker-compose up -d` and look at your lighter shiny app in your `https://localhost:3838`

