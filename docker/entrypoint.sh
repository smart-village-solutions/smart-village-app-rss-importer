#!/bin/sh

set -e

DB=${DB_HOST:-db:5432}

dockerize -wait tcp://$DB -timeout 30s

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

# npm set audit false
bundle exec rake db:migrate

exec "$@"
