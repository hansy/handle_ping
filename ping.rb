require 'open-uri'
require 'open_uri_redirections'

threads = []
handles = {
  'Twitter'   => 'http://www.twitter.com/hansy',
  'Instagram' => 'http://www.instagram.com/hansy'
}

def ping(service, uri)
  puts "Pinging #{service}: #{uri}"
  begin
    open(uri, allow_redirections: :all)
    puts "** #{service} handle not available **"
  rescue OpenURI::HTTPError => e
    send_email(service, uri)
  end
end

def send_email(service, uri)
  puts "** #{service} handle not in use! #{uri} **"
end

puts ENV['POOP']
puts "Checking handles at #{Time.now}"

handles.each do |key, value|
  threads << Thread.new { ping(key, value) }
end

threads.each do |t|
  t.join
end

puts "Finish checking handles at #{Time.now}"

