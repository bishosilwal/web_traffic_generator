
require 'rubygems'
require 'selenium-webdriver'
require 'tormanager'

HOST = 'https://mailet.in'
USER_AGENT = [
	"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.246",
	"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; Media Center PC 6.0; InfoPath.3; MS-RTC LM 8; Zune 4.7)",
	"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0; .NET CLR 2.0.50727; SLCC2; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; Zune 4.0; Tablet PC 2.0; InfoPath.3; .NET4.0C; .NET4.0E)",
	"Mozilla/5.0 (compatible, MSIE 11, Windows NT 6.3; Trident/7.0;  rv:11.0) like Gecko",
	"Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10",
	"Mozilla/5.0 (Windows; U; Windows NT 6.1; ko-KR) AppleWebKit/533.20.25 (KHTML, like Gecko) Version/5.0.4 Safari/533.20.27",
	"Mozilla/5.0 (Windows; U; Windows NT 5.1; ru-RU) AppleWebKit/533.19.4 (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4",
	"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; en-us) AppleWebKit/534.16+ (KHTML, like Gecko) Version/5.0.3 Safari/533.19.4",
	"Opera/9.80 (X11; Linux i686; Ubuntu/14.10) Presto/2.12.388 Version/12.16",
	"Opera/12.0(Windows NT 5.2;U;en)Presto/22.9.168 Version/12.00",
	"Opera/9.80 (X11; Linux x86_64; U; bg) Presto/2.8.131 Version/11.10",
	"Opera/9.80 (Windows NT 5.1; U; MRA 5.6 (build 03278); ru) Presto/2.6.30 Version/10.63",
	"Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
	"Mozilla/5.0 (Linux; U; Android 2.3.5; zh-cn; HTC_IncredibleS_S710e Build/GRJ90) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
	"Mozilla/5.0 (Linux; U; Android 2.2.1; en-ca; LG-P505R Build/FRG83) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
	"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36",
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1944.0 Safari/537.36",
	"Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1500.55 Safari/537.36",
	"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.517 Safari/537.36"
]
PORT_POOL = { 
	9050 => 50501,
	9051 => 50502, 
	9052 => 50503, 
	9053 => 50504, 
	9054 => 50505, 
	9055 => 50506, 
	9056 => 50507, 
	9057 => 50508,
	9058 => 50509,
	9059 => 50510,
	9060 => 50511,
	9061 => 50512,
	9062 => 50513,
	9063 => 50514,
	9064 => 50515,
	9065 => 50516,
	9066 => 50517,
	9067 => 50518,
	9068 => 50519,
	9069 => 50520,
	9070 => 50521,
	9071 => 50522,
	9072 => 50523,
	9073 => 50524,
	9074 => 50525,
	9075 => 50526,
	9076 => 50527,
	9077 => 50528,
	9078 => 50529,
	9079 => 50530
}

used_ports = []
threads = []

mutex = Mutex.new

begin
	30.times do
		current_port = PORT_POOL.keys.sample
		until !used_ports.include?(current_port) do
			current_port = PORT_POOL.keys.sample
		end
		used_ports << current_port
		threads << Thread.new do
			puts "using port: #{current_port}"
			# tor configuration
			tor_process =TorManager::TorProcess.new tor_port: current_port,
			                             control_port: PORT_POOL[current_port],
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
			options.add_argument("--user-agent=#{USER_AGENT.sample}")
			browser = Selenium::WebDriver.for(:chrome, desired_capabilities: cap, options: options)

			tor_process.start

			20.times do |i|
				rand(2..5).times do
					puts "make request to #{HOST}"
					begin
						browser.get(HOST)
					rescue

					end
				end

				begin
					mutex.synchronize do
						puts "changing ip(count: #{i})..."
						tor_ip_control.get_new_ip
					end
				rescue
					puts "IP change failed, running tor on port: #{current_port} failed to change ip!"
				end

				if(i % 3 == 0)
					mutex.synchronize do
						tor_process.stop
						tor_process.start
						browser.quit

						options.add_argument("--user-agent=#{USER_AGENT.sample}")
						browser = Selenium::WebDriver.for(:chrome, desired_capabilities: cap, options: options)
					end
				end
			end

			tor_process.stop

			wait = Selenium::WebDriver::Wait.new(timeout: 30)
			begin
				wait.until { !browser.find_element(class: 'mail').text.empty? }
			rescue
			end
			browser.quit
		end
	end

	threads.each {|thr| thr.join }
ensure
	# stop all eye monitoring process
	system('eye q -s')
end