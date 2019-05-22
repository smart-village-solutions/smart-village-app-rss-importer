#!/bin/sh

set -e

unset BUNDLE_PATH
unset BUNDLE_BIN

# Remove a potentially pre-existing server.pid for Rails.
rm -f /myapp/tmp/pids/server.pid

npm set audit false
rake db:create
rake db:migrate

exec "$@"
