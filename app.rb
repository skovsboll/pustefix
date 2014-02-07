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

require_relative 'app/GitLogParser'


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

      Dir.glob(File.join(project_path, '**/')).map { |dir|
        files = Dir.glob(File.join(dir, '*'))
        .map do |file|
          {file: file, ext: File.extname(file).gsub(/\./, '')}
        end
        .select do |item|
          File.file?(item[:file]) && file_types[item[:ext]]
        end
        .map do |item|
          file_path = item[:file]
          contents = File.read(file_path) rescue 'Invalid contents'
          {name: File.basename(file_path),
           contents: contents,
           path: file_path,
           syntax: file_types[item[:ext]],
           history: File.join('/api/history/', file_path)}
        end
        relative_dir = dir.gsub project_path, ''
        {name: relative_dir, files: files}
      }.reject { |d| d[:files].empty? }
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
      halt 404 unless File.exist? project_path
      api_path = '/api/tree/' + params[:splat]*'/'
      slim :index, :locals => {path: api_path,
                               modes: find_modes(project_path)}
    end

    get '/api/tree/*' do
      project_path = File.expand_path(File.join('~', params[:splat]*'/'))
      halt 404 unless File.exist? project_path
      folders = enumerate_folders(project_path)
      project = {project_name: File.basename(project_path), folders: folders}
      json project
    end

    get '/api/history/*' do
      file_path = File.expand_path(File.join('~', params[:splat]*'/'))
      halt 404 unless File.exist? file_path
      versions = []
      Dir.chdir File.dirname(file_path) do
        relative_file_path = file_path.gsub(Dir.getwd + '/', '')
        raw_history = `git log --pretty="%H %cd %ae %s" -- #{relative_file_path}`
        log_parser = GitLogParser.new
        versions = raw_history.each_line.map do |line|
          commit = log_parser.parse_line line
          contents = `git show #{commit.sha}:#{relative_file_path}`
          {path: file_path, contents: contents, sha: commit.sha, date: commit.date, email: commit.email, comment: commit.comment}
        end
      end
      json versions
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
