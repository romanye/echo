require "rubygems"
require "spork"

ENV["RAILS_ENV"] ||= "test"

Spork.prefork do
  require File.expand_path("../../config/environment", __FILE__)
  require "rspec/rails"

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end

Spork.each_run do
  RSpec.configure do |config|
    config.mock_with :mocha

    # Clean up all collections before each spec runs.
    config.before do
      Mongoid.purge!
    end

    # This filter is here to stub out the Facebook and Twitter services
    # conveniently for each spec tagged with :following.
    config.filter_run_including(service: ->(value) {
      if value == :following
        FollowingObserver.any_instance.stubs(:after_create)
      end
      return true
    })
  end
end
