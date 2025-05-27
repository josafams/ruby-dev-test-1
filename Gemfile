source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

gem 'rails', '~> 7.1.3'
gem 'sprockets-rails'
gem 'sqlite3', '~> 1.4'
gem 'puma', '>= 5.0'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder'
gem 'redis', '>= 4.0.1'
gem 'tzinfo-data', platforms: %i[windows jruby]
gem 'bootsnap', require: false

# Paginação retry e loggers (rollbar ou etc também poderia ser usado)
gem 'kaminari'
gem 'retries'
gem 'semantic_logger'

group :development, :test do
  gem 'pry' # pry >>> byebug
  gem 'bullet'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
end

group :development do
  gem 'web-console'
  gem "rack-mini-profiler"
  gem "spring"
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end
