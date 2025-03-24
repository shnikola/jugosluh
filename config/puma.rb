workers 0
threads 1, 3

preload_app!

rackup      'config.ru'
environment ENV['RACK_ENV'] || 'development'
port ENV.fetch("PORT") { 3000 }

if ENV['RAILS_ENV'] == 'production'
  shared_dir = "/home/deploy/jugosluh/shared"

  # Set up socket location
  bind "unix://#{shared_dir}/tmp/sockets/puma.sock"

  # Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

  # Set master PID and state locations
  pidfile "#{shared_dir}/tmp/pids/puma.pid"
  state_path "#{shared_dir}/tmp/pids/puma.state"

  activate_control_app

  plugin :tmp_restart
end