require 'rack'
#require 'rack-timeout'
#require 'opal'
#require 'opal-sprockets'

require './app'

#use Rack::Timeout
#use Rack::Deflater

#apps = []
#apps << MyApp.new
#
#apps << Opal::Server.new { |s|
#  s.main = 'app'
#  s.append_path 'opal'
#  s.debug = true
#}
#
#run Rack::Cascade.new(apps)
#

run MyApp