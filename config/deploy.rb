require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/systemd'

set :domain, 'utorkom' # Hostname to SSH to
set :port, 20022
set :deploy_to, '/home/deploy/jugosluh'
set :repository, 'https://github.com/shnikola/jugosluh.git'
set :branch, 'master'
set :rails_env, 'production'
set :user, 'deploy'

set :shared_dirs, fetch(:shared_dirs, []).push('tmp/pids', 'tmp/sockets')
set :shared_files, fetch(:shared_files, []).push('.rbenv-vars')

task :environment do
  invoke :'rbenv:load'
end

task setup: :environment do
  command %[touch "#{fetch(:shared_path)}/.rbenv-vars"]
  command %[chmod g+rx,u+rwx "#{fetch(:shared_path)}/.rbenv-vars"]
  comment %{Be sure to set all ENV variables in #{fetch(:shared_path)}/.rbenv-vars}
end

desc "Deploys the current version to the server."
task deploy: :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'systemctl:restart', 'jugosluh-puma'
    end
  end
end

task console: :environment do
  invoke :'console'
end
