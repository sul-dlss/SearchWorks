# This is a shell enviornment that allows us to
# deploy to preview prod and preview stage at the same time.
# This is required because each environemnt has its own db
# and if they are two servers in the same enviornment then
# only the primary (i.e. the first defined) will get db migrations.
task :deploy_preview do
  puts 'deploying preview prod'
  system('cap preview_prod deploy')
  puts 'deploying preview stage'
  system('cap preview_stage deploy')
end
