source 'https://rubygems.org'

gem 'rails', '~> 4.2.10'

gem 'devise', '~> 4.1.1'
gem 'devise-i18n'

gem 'uglifier', '>= 1.3.0'

gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'russian'
gem 'twitter-bootstrap-rails'

group :development, :test do
  gem 'byebug'
  gem 'sqlite3', '~> 1.3.13'

  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 3.4'
  gem 'rubocop'
  gem 'shoulda-matchers'
end

group :test do
  gem 'capybara'
  gem 'launchy'
end

group :production do
  # гем, улучшающий вывод логов на Heroku
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#heroku-gems
  gem 'pg'
  gem 'rails_12factor'
end
