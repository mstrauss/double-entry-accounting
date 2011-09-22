namespace :db do
  desc 'Drop and rebuild database from scratch.'
  task :rebuild => ['drop', 'create', 'migrate', 'seed', 'db:structure:dump']

end
