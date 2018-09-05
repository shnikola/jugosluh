require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

require 'mina/unicorn'

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, 'jugosluh'
set :domain, 'pomice'
set :deploy_to, '/home/app/jugosluh'
set :repository, 'https://github.com/shnikola/jugosluh.git'
set :branch, 'master'

set :user, 'app'
set :port, 20022

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log', 'tmp/sockets', 'tmp/pids']

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'unicorn:restart'
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end
