ENV["RAILS_ENV"] = "test"
require_relative '../config/environment'
require "rails/test_help"
require "minitest/rails"
require "minitest/reporters"

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
# require "minitest/pride"

if ENV['MINITEST_REPORTER'] == 'RUBYMINE'
  Minitest::Reporters.use! Minitest::Reporters::RubyMineReporter.new
# elsif RUBY_ENGINE != 'jruby'
else
  Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new
end

# class ActiveSupport::TestCase
    # ActiveRecord::Migration.check_pending!

    # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
# end
