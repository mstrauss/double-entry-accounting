namespace :db do
  desc 'Drop and rebuild database from scratch.'
  task :rebuild => ['drop', 'create', 'migrate', 'seed', 'schema:dump']

end
