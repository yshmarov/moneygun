# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t moneygun .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name moneygun moneygun

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.5
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client tzdata && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    JEMALLOC_ENABLED="true" \
    MALLOC_ARENA_MAX="2" \
    MALLOC_CONF="dirty_decay_ms:1000,narenas:2,background_thread:true" \
    RUBY_YJIT_ENABLE="1" \
    SENSIBLE_DEFAULTS="enabled" \
    SOLID_QUEUE_IN_PUMA="true"

# Add bundle bin to PATH so bundler and gem executables are available
ENV PATH="/usr/local/bundle/bin:${PATH}"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and compile assets (Node.js for Tailwind CSS v4)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config curl ca-certificates gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y nodejs && \
    node --version && npm --version && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install latest bundler (compatible with Gemfile.lock)
RUN gem install bundler --no-document && \
    bundle --version && \
    which bundle

# Install application gems
# Copy Gemfile, Gemfile.lock, and .ruby-version (needed by Gemfile's "ruby file:" directive)
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install --verbose && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git 2>/dev/null || true && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# Tailwind CSS v4 compilation happens automatically during assets:precompile
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile && \
    rm -rf tmp/cache app/assets/builds/* node_modules/.cache




# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp public
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose common ports for different providers:
# - Port 80: Fly.io, Kamal (Thruster default)
# - Port 3000: Render, Heroku containers, Railway (Puma default)
# Providers can map their ports to either of these
EXPOSE 80 3000

# Health check for container orchestration
# Checks port 3000 (Puma default)
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

# Start server via Puma directly (runs on port 3000, configurable via PORT env var)
# Fly.io will proxy to this port automatically
# For other providers, PORT env var will be set automatically
CMD ["./bin/rails", "server"]
