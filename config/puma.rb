# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 1, 6

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
port ENV.fetch("PORT") { 3000 }

environment ENV.fetch("RAILS_ENV") { "development" }

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

preload_app!

on_worker_boot do
  ApplicationRecord.establish_connection
end
