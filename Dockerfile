# Use the official Ruby 3.2 image as a base image
ARG RUBY_VERSION=3.2
FROM ruby:${RUBY_VERSION}-bullseye

# Set the working directory
WORKDIR /usr/src/app

# Install system packages
RUN apt-get update -qq && \
    apt-get install -y default-mysql-client postgresql postgresql-contrib vim && \
    apt-get clean

# Copy all files
COPY . .

RUN bundler config set --local without "db2 oracle sqlserver sqlite postgresql"
# Move sample database.yml and install gems
RUN mv test/connections/databases.example.yml test/connections/databases.yml && \
    bundle install

CMD ["irb"]
