# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t find_recipes .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name find_recipes find_recipes

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.4
FROM ruby:$RUBY_VERSION-slim

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    postgresql-client \
    curl \
    libjemalloc2 \
    libvips \
    && rm -rf /var/lib/apt/lists/*

# Rails app lives here
WORKDIR /app

# Set environment
ARG RAILS_ENV=development
ENV RAILS_ENV=${RAILS_ENV} \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT=${RAILS_ENV == "development" ? "" : "development:test"}

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN if [ "$RAILS_ENV" = "production" ]; then \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile; \
    fi

# Remove a potentially pre-existing server.pid for Rails
RUN rm -f tmp/pids/server.pid

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
