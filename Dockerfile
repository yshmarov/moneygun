# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t moneygun .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name moneygun moneygun

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=4.0.5
ARG CLAMAV_VERSION=1.4.5
ARG CLAMAV_SHA256=49b7d9592c13e8834fd1e2339bf22b2fabe378317393b51b3879de8520c5b01f
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    ln -s /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment variables and enable jemalloc for reduced memory usage and latency.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LD_PRELOAD="/usr/local/lib/libjemalloc.so"

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock .ruby-version ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile


# Final stage for app image
FROM base
ARG CLAMAV_VERSION
ARG CLAMAV_SHA256

# Install packages needed for deployment
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y imagemagick libimage-exiftool-perl libvips && \
    curl -fsSL "https://github.com/Cisco-Talos/clamav/releases/download/clamav-${CLAMAV_VERSION}/clamav-${CLAMAV_VERSION}.linux.x86_64.deb" -o /tmp/clamav.deb && \
    echo "${CLAMAV_SHA256}  /tmp/clamav.deb" | sha256sum -c - && \
    dpkg -i /tmp/clamav.deb && \
    rm /tmp/clamav.deb && \
    cp /usr/local/etc/freshclam.conf.sample /usr/local/etc/freshclam.conf && \
    sed -i -e 's/^Example/#Example/' -e '$aDatabaseDirectory /var/lib/clamav' /usr/local/etc/freshclam.conf && \
    clamscan --version | grep -F "ClamAV ${CLAMAV_VERSION}" && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    mkdir -p db log storage tmp /var/lib/clamav && \
    chown -R rails:rails db log storage tmp /var/lib/clamav
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
EXPOSE 80
CMD ["bundle", "exec", "thrust", "./bin/rails", "server"]
