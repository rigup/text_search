require 'rubygems'
require 'spork'
require 'rake'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../dummy/config/environment.rb",  __FILE__)
  ActiveRecord::Migrator.migrations_paths = [File.expand_path("../dummy/db/migrate", __FILE__)]

  require 'rspec/rails'
  require 'database_cleaner'

  # Load support files
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  # Load fixtures from the engine
  if ActiveSupport::TestCase.respond_to?(:fixture_path=)
    ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
    ActiveSupport::TestCase.fixtures :all
  end

  # Checks for pending migrations before tests are run.
  # If you are not using ActiveRecord, you can remove this line.
  ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

  RSpec.configure do |config|
    config.include ActionDispatch::TestProcess

    # Deprecation workarounds caused by upgrade to Rspec 2.99
    config.expose_current_running_example_as :example
    config.infer_spec_type_from_file_location!

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false
    config.fixture_path = File.expand_path("../fixtures", __FILE__)

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"

    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation, {:except => %w[public.schema_migrations]})

      # Clear test logs and temp directory
      Rails.application.load_tasks
      Rake::Task['tmp:clear'].invoke
      Rake::Task['log:clear'].invoke
    end

    DatabaseCleaner.strategy = :deletion, {:except => %w[public.schema_migrations]}

    config.around(:each) do |example|
      DatabaseCleaner.cleaning do
        example.run
      end
    end

  end
end
