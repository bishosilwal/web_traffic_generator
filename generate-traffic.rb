
require 'rubygems'
require 'selenium-webdriver'
require 'tormanager'

threads = []
port_pool = { 
	9050 => 50501,
	9051 => 50502 , 
	9052 => 50503, 
	9053 => 50504, 
	9054 => 50505, 
	9055 => 50506, 
	9056 => 50507, 
	9057 => 50508,
	9058 => 50509,
	9059 => 50510
}

used_ports = []

HOST = 'https://mailet.in'

mutex = Mutex.new

begin
	10.times do 
		current_port = port_pool.keys.sample
		until !used_ports.include?(current_port) do
			current_port = port_pool.keys.sample
		end
		used_ports << current_port

		threads << Thread.new do
			puts "using port: #{current_port}"
			# tor configuration
			tor_process =TorManager::TorProcess.new tor_port: current_port,
			                             control_port: port_pool[current_port],
			                             pid_dir: '/Users/silwal/files/workspace/traffic-generator/tor/pid/dir',
			                             log_dir: '/Users/silwal/files/workspace/traffic-generator/tor/log/dir',
			                             tor_data_dir: '/Users/silwal/files/workspace/traffic-generator/tor/datadir',
			                             tor_new_circuit_period: 15,
			                             max_tor_memory_usage_mb: 400,
			                             max_tor_cpu_percentage: 15,
			                             eye_logging: true,
			                             tor_logging: true

			tor_proxy = TorManager::Proxy.new tor_process: tor_process
			tor_ip_control = TorManager::IpAddressControl.new tor_process: tor_process, tor_proxy: tor_proxy
			# selenium configuration
			proxy = Selenium::WebDriver::Proxy.new(socks: "127.0.0.1:#{current_port}", socks_version: 5)
			cap   = Selenium::WebDriver::Remote::Capabilities.chrome(proxy: proxy)
			options = Selenium::WebDriver::Chrome::Options.new
			options.headless!
			# generate random user agent
			options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36")

			browser = Selenium::WebDriver.for(:chrome, desired_capabilities: cap, options: options)
			
			tor_process.start

			20.times do |i|
				rand(2..5).times do
					puts "make request to #{HOST}"
					browser.get(HOST)
				end

				begin
					mutex.synchronize do
						puts "changing ip(count: #{i})..."
						tor_ip_control.get_new_ip
					end
				rescue
					puts "IP change failed, running tor on port: #{current_port} failed to change ip!"
				end

				if(i % 5 == 0)
					mutex.synchronize do
						tor_process.stop
						tor_process.start
					end
				end
			end

			tor_process.stop

			wait = Selenium::WebDriver::Wait.new(timeout: 30)
			wait.until { !browser.find_element(class: 'mail').text.empty? }
			browser.quit
		end
	end

	threads.each {|thr| thr.join }
ensure
	# stop all eye monitoring process
	system('eye q -s')
end
