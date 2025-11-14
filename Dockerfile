# TODO: be careful: devxy uses arm instead of amd 

# uses: devxygmbh/r-alpine:4-3.21
# use: postgres -> image -> see docker-compose.yml von h4sci-survey (=post)

FROM devxygmbh/r-alpine:4-3.21

# Install OS deps needed for Postgres + Shiny
RUN apk add --no-cache \
      postgresql-client \
      postgresql-libs \
      postgresql-dev \
      g++ \
      make \
      libc6-compat \
      curl

# Install R packages (Shiny + Postgres)
RUN R -q -e "install.packages(c('shiny','DBI','RPostgres'), repos='https://cloud.r-project.org')"

# Copy app
WORKDIR /app
COPY app ./app

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('app', host='0.0.0.0', port=3838)"]
