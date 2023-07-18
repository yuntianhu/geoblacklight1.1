# Base image
FROM ruby:3.2.0
FROM ubuntu:latest

# Set environment variables
ENV RAILS_ENV=development
ENV NODE_ENV=development
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  gnupg2 \
  default-jre \
  nodejs \
  mysql-client \
  rbenv

# Install Ruby using rbenv
RUN apt-get install -y \
  git \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  build-essential \
  libsqlite3-dev \
  libpq-dev \
  libmysqlclient-dev

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
  echo 'export PATH="/HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
  echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
  exec $SHELL

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
  echo 'export PATH="/HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc && \
  exec $SHELL

RUN rbenv install 3.2.0 && \
  rbenv global 3.2.0

# Install Bundler and Rails
RUN gem install bundler:2.2.28
RUN gem install rails:7.0.4

# Install Node.js and Yarn
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

# Install Java
RUN apt-get install -y openjdk-8-jre-headless

# Install MySQL client
RUN apt-get install -y default-mysql-client

# Install the project
RUN mkdir -p /app
WORKDIR /app
COPY . /app

# Install Ruby dependencies
RUN bundle install --jobs 4 --retry 3

# Install JavaScript dependencies
RUN yarn install

# Create and migrate databases
RUN bundle exec rails db:create
RUN bundle exec rails db:migrate

# Expose ports
EXPOSE 3000
EXPOSE 8983

# Start the application
CMD ["bundle", "exec", "rake", "umass:server"]
