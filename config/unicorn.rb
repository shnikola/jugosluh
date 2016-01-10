# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/home/jugosluh/current"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/home/jugosluh/current/tmp/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path "/home/jugosluh/current/log/unicorn.log"
stdout_path "/home/jugosluh/current/log/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.jugosluh.sock"

# Number of processes
# worker_processes 4
worker_processes 1

# Time-out
timeout 30

user "nikola"
