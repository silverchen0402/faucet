#!/bin/bash
# Interpreter identifier

set -e
# Exit on fail

mkdir tmp/sockets || echo 0
mkdir tmp/pids || echo 0
rm tmp/pids/unicorn.pid || echo 0

bundle check || bundle install --binstubs="$BUNDLE_BIN"
# Ensure all gems installed. Add binstubs to bin which has been added to PATH in Dockerfile.

# rake db:migrate
# Migrate db


# BUNDLE_PATH="$BUNDLE_PATH" \
#   RAILS_ENV="$RAILS_ENV" \
#   CRON_LOG_PATH='/app/log/cron_log.log' \
#   whenever --update-crontab
# Update crontab

cron
# Start cron daemon

exec "$@"
# Finally call command issued to the docker service

