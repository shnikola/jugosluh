# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 21 6

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
port ENV.fetch("PORT") { 3000 }

environment ENV.fetch("RAILS_ENV") { "development" }

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
preload_app!

activate_control_app

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
#
on_worker_boot do
  ApplicationRecord.establish_connection
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# when running rails in development and connecting a graphical ide debugger
# extend worker_timeout - otherwise debugging sessions timeout
if ENV['RAILS_ENV'] == 'development' && ENV['IDE_PROCESS_DISPATCHER']
  worker_timeout 60 * 60 * 24
end
