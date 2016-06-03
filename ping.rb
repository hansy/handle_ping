require 'open-uri'
require 'open_uri_redirections'
require 'mail'

HANDLE_URI_FORMAT = {
  'TWITTER'   => "http://www.twitter.com/:username",
  'INSTAGRAM' => "http://www.instagram.com/:username"
}

mail_options = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'your.host.name',
  user_name:            ENV['EMAIL_USERNAME'],
  password:             ENV['EMAIL_PASSWORD'],
  authentication:       'plain',
  enable_starttls_auto: true
}

Mail.defaults do
  delivery_method :smtp, mail_options
end

def ping(service, uri)
  puts "Pinging #{service}: #{uri}"
  begin
    open(uri, allow_redirections: :all)
    puts "** #{service} handle unavailable **"
  rescue OpenURI::HTTPError => e
    msg = "#{service} handle possibly available"
    puts "** #{msg} **"
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

# Service handles stored as environment variables with format:
# <SERVICE NAME>_HANDLE = <HANDLE VALUE>
def get_handles
  handles = {}

  # Loop through all env vars
  ENV.each do |k, v|
    # Find env vars matching format
    if k.include? '_HANDLE'
      # Get service name
      service = k.split('_').first 

      # Get URI specific to service and replace stubbed username part
      # with HANDLE VALUE
      uri = HANDLE_URI_FORMAT[service].gsub(':username', v)

      handles[service] = uri
    end
  end

  return handles
end

puts "Checking handles at #{Time.now}"

threads = []
handles = get_handles

handles.each do |key, value|
  threads << Thread.new { ping(key, value) }
end

threads.each do |t|
  t.join
end

system("heroku config:set FOO=bar")

puts "Finish checking handles at #{Time.now}"

