source 'https://rubygems.org'
gem 'rails', '3.2.13'

gem "pg", ">= 0.15.0"
gem "mongo"
gem "mongoid"
gem "coveralls", :require => false
gem "bson_ext"
gem "devise", ">= 2.2.3"
gem "devise_invitable", ">= 1.1.5"
gem "cancan", ">= 1.6.9"
gem "rolify", ">= 3.2.0"
# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'jquery-rails'
  gem "knockout-rails"
  gem "coffee-rails"
  gem "typescript-rails"
  gem "qunit-rails"
  gem "tweetstream"
  gem 'uglifier', '>= 1.0.3'
  gem 'sass-rails'
  gem "twitter-bootstrap-rails", ">= 2.2.4"
end

group :development, :test do
	gem "rspec-rails", ">= 2.12.2"
	gem "capybara", ">= 2.0.3"
end

group :test do
	gem "database_cleaner", ">= 1.0.0.RC1"	
	gem "email_spec", ">= 1.4.0"
	gem "rake"
end

group :development do
	gem "guard-bundler", ">= 1.0.0"
	gem "guard-rails", ">= 0.4.0"
	gem "guard-rspec", ">= 2.5.2"
	gem "rb-inotify", ">= 0.9.0", :require => false
	gem "rb-fsevent", ">= 0.9.3", :require => false
	gem "rb-fchange", ">= 0.0.6", :require => false
	gem "quiet_assets", ">= 1.0.2"
	gem "better_errors", ">= 0.7.2"
	gem "binding_of_caller", ">= 0.7.1", :platforms => [:mri_19, :rbx]
end

group :development, :test do
	gem "factory_girl_rails", ">= 4.2.0"
end
