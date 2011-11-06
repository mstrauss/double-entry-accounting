namespace :db do
  desc 'Drop and rebuild database from scratch.'
  task :rebuild => ['drop', 'create', 'migrate', 'seed', 'db:structure:dump']


  namespace :test do |s|
    s[:prepare].clear
  end
  
  namespace :test do
    task :prepare => ['drop', 'create', 'migrate', 'seed', 'db:structure:dump']
  end

end
