#!/usr/bin/env ruby

# Libraries:::::::::::::::::::::::::::::::::::::::::::::::::::::::
require 'rubygems'
require 'sinatra/base'
require 'sinatra/contrib'

require 'slim'
require 'stylus'
require 'stylus/tilt'
require 'json'

require 'opal'
require 'opal-jquery'


module Pustefix
# Application:::::::::::::::::::::::::::::::::::::::::::::::::::
  class StylusHandler < Sinatra::Base
    set :views, File.dirname(__FILE__) + '/stylus'

    get '/css/styles.css' do
      stylus :styles
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

  class Api < Sinatra::Base
    get '/api/*' do
      project_path = File.expand_path(File.join('~', params[:splat]*'/'))
      puts project_path
      folders = Dir.glob(File.join(project_path, '**/*/')).map do |dir|
        files = Dir.glob(File.join(dir, '*.rb')).map do |file|
          {name: File.basename(file),
           contents: File.read(file),
           path: file,
           syntax: 'ruby',
           history: []
          }
        end
        {name: dir, files: files}
      end
      folders.reject! { |d| d[:files].empty? }
      project = {project_name: File.basename(project_path), folders: folders}
      json project
    end
  end

  class MyApp < Sinatra::Base
    use StylusHandler
    use Api
    #use OpalHandler

    # Configuration:::::::::::::::::::::::::::::::::::::::::::::::
    set :public_folder, File.dirname(__FILE__) + '/static'
    set :views, File.dirname(__FILE__) + '/views'

    # Route Handlers::::::::::::::::::::::::::::::::::::::::::::::
    get '/projects/*' do
      api_path = '/api/' + params[:splat]*'/'
      slim :index, :locals => {path: api_path}
    end
  end
end
