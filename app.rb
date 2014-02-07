#!/usr/bin/env ruby

# Libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'rubygems'
require 'sinatra/base'
require 'slim'
require 'stylus'
require 'stylus/tilt'

require 'opal'
require 'opal-jquery'

# Application:::::::::::::::::::::::::::::::::::::::::::::::::::
class StylusHandler < Sinatra::Base

  set :views, File.dirname(__FILE__) + '/stylus'

  get '/css/main.css' do
    stylus :main
  end

end

class OpalHandler < Sinatra::Base

  get '/js/*.js' do
    filename = params[:splat].first
    opal_builder = Opal::Builder.new
    opal_builder.append_path File.dirname(__FILE__) + '/opal'
    opal_builder.build filename.to_sym
  end
end

class MyApp < Sinatra::Base
  use StylusHandler
  use OpalHandler

  # Configuration:::::::::::::::::::::::::::::::::::::::::::::::
  set :public_folder, File.dirname(__FILE__) + '/static'
  set :views, File.dirname(__FILE__) + '/views'

  # Route Handlers::::::::::::::::::::::::::::::::::::::::::::::
  get '/' do
    slim :index
  end

end

if __FILE__ == $0
  MyApp.run! :port => 4567
end