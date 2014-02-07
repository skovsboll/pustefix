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
    def enumerate_folders(project_path)

      file_types = YAML.load_file File.join(File.dirname(__FILE__), 'config/modes.yaml')

      Dir.glob(File.join(project_path, '**/')).map do |dir|
        puts dir
        files = Dir.glob(File.join(dir, '*'))
        .select do |file|
          ext = File.extname(file).gsub /\./, ''
          File.file?(file) && file_types[ext]
        end.map do |file|
          ext = File.extname(file).gsub /\./, ''
          text_contents = File.read(file)

          begin
            text_contents.to_json
            {name: File.basename(file),
             contents: text_contents,
             path: file,
             syntax: file_types[ext],
             history: []
            }
          rescue
            {
              name: File.basename(file),
              contents: 'invalid contents'
            }
          end

        end
        {name: dir, files: files}
      end.reject { |d| d[:files].empty? }
    end

    def find_modes(project_path)
      file_types = YAML.load_file File.join(File.dirname(__FILE__), 'config/modes.yaml')

      Dir.glob(File.join(project_path, '**/*'))
      .select { |file| File.file?(file) }
      .map { |file| File.extname(file).gsub /\./, '' }
      .select { |ext| file_types[ext] }
      .map { |ext| file_types[ext] }
      .compact
      .uniq
    end


    # ROUTES

    get '/projects/*' do
      project_path = File.expand_path(File.join('~', params[:splat]*'/'))
      api_path = '/api/' + params[:splat]*'/'
      slim :index, :locals => {path: api_path, modes: find_modes(project_path)}
    end

    get '/api/*' do
      project_path = File.expand_path(File.join('~', params[:splat]*'/'))
      folders = enumerate_folders(project_path)
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

  end
end
