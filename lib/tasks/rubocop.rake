# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = true
  end
rescue LoadError
  # No warning because we expect that Rubocop will not be present in production
  # and we would prefer not to see a warning in cron output every day.
end
