#!/bin/sh

#bundle exec whenever --write-crontab
#crond -f

bundle exec rails runner "RssFeeds.import"
