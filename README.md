# How to use this project to setup your Rails application via docker simplely


## Add some files into the project

 - add .dockerignore file into the root directory of the project

```
# .dockerignore file
.git*
db/*.sqlite3
db/*.sqlite3-journal
log/*
tmp/*
Dockerfile
README.rdoc
```

 - add Dockerfile file into the root directory of the project

```
# Dockerfile file

FROM ruby:2.3.1

# don't use httpredir.debian.org mirror as it's very unreliable
# RUN echo deb http://ftp.us.debian.org/debian jessie main > /etc/apt/sources.list


# use aliyun mirror source
RUN echo deb http://mirrors.aliyun.com/debian jessie main > /etc/apt/sources.list


# RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# Install dependencies
RUN apt-get update && apt-get install -y build-essential libssl-dev libpq-dev libxml2-dev libxslt1-dev nodejs sqlite3 git imagemagick libbz2-dev libjpeg-dev libevent-dev libmagickcore-dev libffi-dev libglib2.0-dev zlib1g-dev libyaml-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*


ENV APP_HOME /var/www/app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* ./

RUN gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/ && gem install bundler && bundle config mirror.https://rubygems.org https://gems.ruby-china.org && bundle install --jobs 20 --retry 5

# Static copy the project code into the container, we don't recommend this method.
# ADD . ./

EXPOSE 3000

# run the app in development mode
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# run the app in production mode
# RUN bundle exec rake assets:precompile RAILS_ENV=production
# CMD ["bundle", "exec", "puma", "-C", "config/puma_docker.rb"]

```

 - add docker-compose.yml file into the root directory of the project

```
# docker-compose.yml file

version: '3'

services:
  app:
    build: .
    command: rails server -p 3000 -b '0.0.0.0'
    volumes:
      - .:/var/www/app
      - ./tmp/db:/var/www/app/db/*.sqlite3
    ports:
      - "3000:3000"
```

## How to build the image for your Rails application via Dockerfile file

- build the image via Dockerfile

    `docker build -t docker_rails_demo_with_sqlite3:v1 .`

- verify if image build successfully

    `docker images`

- how to run it as a container

    `docker run --rm --name rails_server_with_sqlite3 -p 3000:3000 -v $(pwd):/var/www/app docker_rails_demo_with_sqlite3:v1 . `

- how to go into the container

    `docker exec -it container_id (container_name) bash`

- how to create the database for the rails application

    `docker exec -it container_id (container_name) bundle exec rails db:drop db:create db:migrate`


## How to build the image for your Rails application via docker-compose.yml file

- build the image via docker-compose.yml file

    `docker-compose build`

- how to start the server up as a container (no need to specify the -v option due to configure them in the docker-compose.yml file)

    `docker-compose up`

- how to go into the container

    `docker exec -it container_id (container_name) bash`

- how to create the database for the rails application

    `docker exec -it container_id (container_name) bundle exec rails db:drop db:create db:migrate`
