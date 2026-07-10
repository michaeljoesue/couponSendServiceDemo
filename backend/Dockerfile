FROM ruby:3.2.2-slim

# Install required packages
RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy Gemfile and install dependencies (including development gems for hot reload)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy entrypoint script and make it executable
COPY bin/docker-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint

# Expose port
EXPOSE 8080

# Use entrypoint script to handle database setup and start server
ENTRYPOINT ["docker-entrypoint"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "8080"]
