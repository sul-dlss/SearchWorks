desc 'Run continuous integration build'
task ci: %i[environment] do
  if Rails.env.test?
    Rake::Task['db:migrate'].invoke
    Rake::Task['spec'].invoke
  else
    system('rake ci RAILS_ENV=test')
  end
end
