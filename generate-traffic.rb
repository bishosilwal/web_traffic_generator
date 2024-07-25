
require 'rubygems'
require 'selenium-webdriver'
require 'pry'
require 'base64'
# For simple HTTP.get
require 'net/http'

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

used_ports = []
threads = []
ip_lists = []
file = File.open("./ip_lists/proxy_ip_lists.txt", 'r')
file.each_line do |line|
	ip_lists << line.gsub("\n", '')
end
file.close
ip_lists = ip_lists.compact

mutex = Mutex.new

begin
	20.times do
		threads << Thread.new do
			sample_ip = ip_lists.sample.strip
			profile = Selenium::WebDriver::Firefox::Profile.new
			proxy = Selenium::WebDriver::Proxy.new(http: sample_ip , ssl: sample_ip, socks: sample_ip)
			profile.proxy = proxy
			options = Selenium::WebDriver::Firefox::Options.new profile: profile
			options.add_argument("--user-agent=#{USER_AGENT.sample}")
			# options.headless!
			browser = Selenium::WebDriver.for :firefox, options: options

			1.times do |i|
				1.times do
					puts "make request to #{HOST}"
					begin
						browser.get(HOST)
						wait = Selenium::WebDriver::Wait.new(timeout: 20) # seconds
						browser.execute_script("window.scrollTo(0, #{rand(500)})")
						wait.until { browser.find_elements(tag_name: 'iframe').length > 3 }
						browser.find_element(tag_name: 'body').click
					rescue => e
						puts "error! #{e}"
					end
				end

				# mutex.synchronize do
				# 	browser.quit

				# 	options.add_argument("--user-agent=#{USER_AGENT.sample}")
				# 	browser = Selenium::WebDriver.for :firefox, options: options
				# end
			end

			# wait = Selenium::WebDriver::Wait.new(timeout: 10)
			# begin
			# 	wait.until { !browser.find_element(class: 'mail').text.empty? }
			# rescue
			# end

			browser.quit

		end
	end

	threads.each {|thr| thr.join }
ensure
	# stop all eye monitoring process
end
