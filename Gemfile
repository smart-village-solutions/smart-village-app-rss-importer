source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.0"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 6.0.0.rc1"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 3.11"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use Active Model has_secure_password
# gem "bcrypt", "~> 3.1.7"

gem "rollbar"
# gem "gelf"

gem "mimemagic", ">= 0.3.6"
gem "status-page"

# Use Active Storage variant
# gem "image_processing", "~> 1.2"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.2", require: false

# Parsing XML documents
gem "nokogiri"

gem "addressable"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

gem "unicorn"
gem "whenever"

gem "cronjob_service"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "annotate"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rb-readline"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "spring"
  gem "codeclimate-test-reporter"
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "factory_bot"
  gem "guard-rspec"
  gem "guard"
  gem "linter", git: "https://github.com/ikuseiGmbH/linters.git", tag: "rubocop-0.63.1"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "shoulda-matchers"
  gem "simplecov"
end


# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
