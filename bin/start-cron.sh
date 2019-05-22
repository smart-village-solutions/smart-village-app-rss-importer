#!/bin/sh

bundle exec whenever --write-crontab
cron -f
