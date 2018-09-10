# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :setup do

  desc "Create index"
  task :index => :environment do
    $artist_repository.create_index!(force: true)
    $album_repository.create_index!(force: true)
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest => ex
    raise unless ex.message =~ /resource_already_exists_exception/
  end
end
