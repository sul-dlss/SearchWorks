namespace :searchworks do
  desc "Run SearchWorks local installation steps"
  task :install => [:environment] do
    Rake::Task["db:migrate"].invoke
    unless File.exists?("#{Rails.root}/jetty")
      Rake::Task["jetty:download"].invoke
      Rake::Task["jetty:unzip"].invoke
    end
  end
end
