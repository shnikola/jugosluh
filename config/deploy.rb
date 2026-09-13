lock '~> 3.20'

set :application, 'jugosluh'
set :repo_url, 'https://github.com/shnikola/jugosluh.git'
set :branch, 'master'
set :deploy_to, '/home/deploy/jugosluh'
set :rails_env, 'production'
set :keep_releases, 5

set :rbenv_type, :user
set :rbenv_ruby, File.read(File.expand_path('../.ruby-version', __dir__)).strip

# Reuse the gem directory mina installed into
set :bundle_path, -> { shared_path.join('vendor/bundle') }

append :linked_dirs, 'log', 'tmp/cache', 'tmp/pids', 'tmp/sockets', 'public/assets'
append :linked_files, '.rbenv-vars'

namespace :deploy do
  desc 'Create shared .rbenv-vars file'
  task :setup do
    on roles(:app) do
      execute :mkdir, '-p', shared_path
      execute :touch, shared_path.join('.rbenv-vars')
      execute :chmod, 'g+rx,u+rwx', shared_path.join('.rbenv-vars')
      info "Be sure to set all ENV variables in #{shared_path}/.rbenv-vars"
    end
  end

  desc 'Restart puma'
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, 'jugosluh-puma'
    end
  end

  after :publishing, :restart
end

desc 'Open a Rails console on the server'
task :console do
  on roles(:app), in: :sequence do |host|
    cmd = "cd #{current_path} && ~/.rbenv/bin/rbenv exec bundle exec rails console -e #{fetch(:rails_env)}"
    exec %(ssh -t -p #{host.port} #{host.user}@#{host.hostname} "#{cmd}")
  end
end
