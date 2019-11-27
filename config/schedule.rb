# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/var/log/cron.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
set :environment, ENV['RAILS_ENV']
env :PATH, ENV['PATH']
env :BUNDLE_PATH, '/usr/local/bundle'
env :GEM_HOME, '/usr/local/bundle'
env :BUNDLE_APP_CONFIG, '/usr/local/bundle'

every 1.hour do
  runner "RssFeeds.import"
end

# Learn more: http://github.com/javan/whenever
