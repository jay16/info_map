#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

$:.unshift(File.dirname(__FILE__))

task :default => [:environment]

desc "set up environment for rake"
task :environment => "Gemfile.lock" do
  require File.expand_path('../config/boot.rb', __FILE__)
  eval "Rack::Builder.new {( " + File.read(File.expand_path('../config.ru', __FILE__)) + "\n )}"
end

task :simple do
  require "settingslogic"
  require "open-uri"
  require "json"
  @options ||= {}
  @options[:rack_env] = ENV["RACK_ENV"] ||= "production"
  ENV["APP_ROOT_PATH"] = @options[:app_root_path] = Dir.pwd
  load "%s/app/models/settings.rb" % @options[:app_root_path]
  require File.expand_path('../config/boot.rb', __FILE__)

  def base_on_root_path(path)
    if @options.has_key?(:app_root_path)
      File.join(@options[:app_root_path], path)
    else
      raise "[dangerous] @options missing key - :app_root_path"
    end
  end

  @options[:weixin_app_id]     = Settings.weixin.app_id
  @options[:weixin_app_secret] = Settings.weixin.app_secret
  @options[:weixin_base_url]   = "https://api.weixin.qq.com/cgi-bin"
end
Dir.glob('lib/tasks/*.rake').each { |file| load file }
