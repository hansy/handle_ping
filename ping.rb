require 'open-uri'
require 'open_uri_redirections'
require 'mail'
require 'pry'

# 3rd party URI patterns for username page
# Values contain urls stubbed with :username, that will be replaced
# with desired handle
HANDLE_URI_PATTERNS = {
  'TWITTER'   => "http://www.twitter.com/:username",
  'INSTAGRAM' => "http://www.instagram.com/:username"
}

mail_options = {
  address:              'smtp.gmail.com',
  port:                 587,
  user_name:            ENV['EMAIL_USERNAME'],
  password:             ENV['EMAIL_PASSWORD'],
  authentication:       'plain',
  enable_starttls_auto: true
}

Mail.defaults do
  delivery_method :smtp, mail_options
end

# GETs username page to check availability
# If open-uri can open page, username unavailable; otherwise, alert via email
def ping(service, uri)
  puts "Pinging #{service}: #{uri}"

  begin
    # open-uri follows redirects; must use open_uri_redirections gem
    # for SSL redirections
    open(uri, allow_redirections: :all)
    puts "** #{service} handle unavailable **"
  rescue OpenURI::HTTPError => e
    msg  = e.message
    code = msg.split(' ').first.to_i

    if code < 500 && code > 399
      msg = "#{service} handle possibly available"
      puts "** #{msg} **"
    end

    send_email(msg, e.message)
  end
end

def send_email(subject, body)
  Mail.deliver do
    to      ENV['EMAIL_USERNAME']
    from    ENV['EMAIL_USERNAME']
    subject subject
    body    body
  end
end

# Desired handles stored as environment variables with format:
# <SERVICE NAME>_HANDLE=<HANDLE VALUE>, e.g. TWITTER_HANDLE=awesomesauce
#
# Read handles from ENV, and return hash with format
# {
#   SEVICE_NAME => SERVICE_URL
# } 
#
# e.g.
#
# {
#   "TWITTER"   => "http://www.twitter.com/awesomesauce",
#   "INSTAGRAM" => "http://www.instagram.com/awesomesauce"
# }
def get_handle_urls
  urls = {}

  # Loop through all env vars
  ENV.each do |k, v|
    # Find env vars matching format
    if k.include? '_HANDLE'
      # Get service name
      service = k.split('_').first 

      # Get URI specific to service and replace stubbed username part
      # with HANDLE VALUE
      uri = HANDLE_URI_PATTERNS[service].gsub(':username', v)

      urls[service] = uri
    end
  end

  return urls
end

puts "Checking handles at #{Time.now}"

threads = []
urls    = get_handle_urls

urls.each do |service_name, url|
  threads << Thread.new { ping(service_name, url) }
end

threads.each do |t| 
  t.join
end

puts "Finish checking handles at #{Time.now}"

