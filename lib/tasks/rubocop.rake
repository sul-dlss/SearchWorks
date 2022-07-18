# frozen_string_literal: true

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = true
  end
rescue LoadError
  warn 'Rubocop was not found and could not be required.'
end
