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
