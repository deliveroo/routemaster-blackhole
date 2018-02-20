default_worker_count = 10
worker_count = ENV['UNICORN_WORKERS'].to_i
worker_processes(worker_count == 0 ? default_worker_count : worker_count)

default_timeout_s = 5
timeout_s = ENV['UNICORN_TIMEOUT'].to_i
timeout(timeout_s == 0 ? default_timeout_s : timeout_s)

default_port_number = 3000
port_number = ENV['PORT'].to_i
listen("0.0.0.0:#{port_number == 0 ? default_port_number : port_number}")

preload_app true

check_client_connection false

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  sleep 100e-3
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end
end
