# Base image
FROM ruby:3.2.0

# Set environment variables
ENV RAILS_ENV=development
ENV NODE_ENV=development

# Install system dependencies
RUN apt-get update && apt-get install -y \
  default-jre \
  nodejs \
  mysql-client

# Install Yarn
RUN apt-get install -y curl && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y yarn

# Install the project
RUN mkdir -p /app
WORKDIR /app
COPY . /app

# Install Ruby dependencies
RUN gem install bundler:2.2.28
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
