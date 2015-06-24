require 'open-uri'
require 'nokogiri'
require 'thread'

base_url = 'https://developer.apple.com/videos/wwdc/2015/'
url_links = {}

doc = Nokogiri::HTML(open(base_url))
links = doc.css('section.video_sections li a')
links.each do |link|
  title = link.text
  url_str = URI.join(base_url, link.attributes['href'].value).to_s
  url_links[title] = url_str
end

semaphore = Mutex.new
threads = []

sd_links = {}
hd_links = {}
pdf_links = {}

url_links.each_pair do |title, link|
  threads << Thread.new {
  	doc = Nokogiri::HTML(open(link))
  	sd_link = doc.xpath("//a[text()='SD']").last.attributes['href'].value
  	hd_link = doc.xpath("//a[text()='HD']").last.attributes['href'].value
    
    pdf_link = doc.xpath("//a[text()='PDF']").last.attributes['href'].value if doc.xpath("//a[text()='PDF']").last

  	semaphore.synchronize {
  		puts "#{title}:  \n\tSD:#{sd_link}\n\tHD:#{hd_link}\n\tPDF:#{pdf_link}\n"
  		sd_links[title] = sd_link
  		hd_links[title] = hd_link
      pdf_links[title] = pdf_link
 	  }
  }
  
end

threads.map { |trd| trd.join }

File.open('wwdc2015-sd.txt', 'w+') { |f| f.write(sd_links.values.join("\n")) }
File.open('wwdc2015-hd.txt', 'w+') { |f| f.write(hd_links.values.join("\n")) }
File.open('wwdc2015-pdf.txt', 'w+') { |f| f.write(pdf_links.values.join("\n")) }