require "rubygems"

root_path = File.dirname(File.dirname(__FILE__))#File.expand_path("../../", __FILE__)
ENV["APP_NAME"]  ||= "info_map"
ENV["RACK_ENV"]  ||= "development"
ENV["VIEW_PATH"]  = "%s/app/views" % root_path
ENV["APP_ROOT_PATH"] = root_path

begin
  ENV["BUNDLE_GEMFILE"] ||= "%s/Gemfile" % root_path
  require "rake"
  require "bundler"
  Bundler.setup
rescue => e
  puts e.backtrace &&  exit
end
Bundler.require(:default, ENV["RACK_ENV"])

# execute linux shell command
# return array with command result
# [execute status, execute result] 
def run_command(cmd)
  IO.popen(cmd) do |stdout|
    stdout.reject(&:empty?)
  end.unshift($?.exitstatus.zero?)
end 

status, *result = run_command("whoami")
if result[0].strip == "root"
  system("chown -R nobody:nobody #{root_path} && chmod -R 777 #{root_path}")
else
  warn "\twarning: [#{result[0].strip}] can't execute chown/chmod"
end

# 扩充require路径数组
# require 文件时会在$:数组中查找是否存在
$:.unshift(root_path)
$:.unshift("%s/config" % root_path)
$:.unshift("%s/lib/tasks" % root_path) 
%w(controllers helpers models).each do |path|
  $:.unshift("%s/app/%s" % [root_path, path])
end

require "lib/utils/boot.rb"
include Utils::Boot

require "lib/utils/action_logger.rb"
recursion_require("lib/utils/core_ext", /\.rb$/, root_path)
# config文夹下为配置信息优先加载
# modle信息已在asset-hanler中加载
# asset-hanel嵌入在application_controller
require "app/models/settings.rb"
require "asset-handler"

# helper will include into controller
# helper load before controller
recursion_require("app/helpers", /_helper\.rb$/, root_path)
recursion_require("app/controllers", /_controller\.rb$/, root_path, [/^application_/])
