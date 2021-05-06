#!/bin/sh

bundle exec whenever --write-crontab
crond -f
