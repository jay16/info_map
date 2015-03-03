#encoding: utf-8
require "json"
require 'digest/md5'
require "sinatra/multi_route"
require 'will_paginate'
require 'will_paginate/data_mapper'  # or data_mapper/sequel
#require 'will_paginate/collection'
class ApplicationController < Sinatra::Base
  set :root, ENV["APP_ROOT_PATH"]
  enable :sessions, :logging, :dump_errors, :raise_errors, :static, :method_override

  # css/js/view配置文档
  use AssetHandler
  use ImageHandler
  use SassHandler
  use CoffeeHandler

  register Sinatra::Reloader if development?
  register Sinatra::MultiRoute
  register Sinatra::Flash
  register SinatraMore::MarkupPlugin
  
  # helpers
  helpers ApplicationHelper
  helpers HomeHelper

  before do
    @request_body = request_body
    request_hash = JSON.parse(@request_body) rescue {}
    @params = params.merge(request_hash)
    @params = @params.merge({ip: remote_ip, browser: remote_browser})

    print_format_logger
  end

  #def self.inherited(subclass)
  #  puts "new subclass: %s" % subclass.to_s if subclass
  #end
  # global functions list
  def remote_ip
    request.ip 
  end
  def remote_path
    request.path 
  end
  def remote_browser
    request.user_agent
  end
  def run_shell(shell, whether_show_log=true)
    _result = IO.popen(shell) do |stdout| 
      stdout.reject(&:empty?) 
    end.unshift($?.exitstatus.zero?)
    if true or !_result[0] or whether_show_log
      _shell  = shell.gsub(ENV["APP_ROOT_PATH"], "=>").split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
      _status = _result[0]
      _res    = _result.length > 1 ? _result[1..-1].map { |line| "\t\t" + line }.join  : "\t\tbash: no output."
      puts "%s\n\t\t==> %s\n%s\n" % [_shell, _status, _res]
    end
    return _result
  end 

  def current_user
    @current_user ||= User.first(email: request.cookies["cookie_user_login_state"] || "")
  end
  # action_logger
  # current_user
  include Utils::ActionLogger

  # filter
  def authenticate! 
    if request.cookies["cookie_user_login_state"].to_s.strip.empty?
      # 记录登陆前的path，登陆成功后返回至此path
      response.set_cookie "cookie_before_login_path", {:value=> request.url, :path => "/", :max_age => "2592000"}

      flash[:notice] = "继续操作前请登录."
      redirect "/user/login", 302
    end
  end

  # format gem#dm-validations errors info
  def format_dv_errors(model)
    errors = []
    model.errors.each_pair do |key, value|
      errors.push({ key => value })
    end
    return errors
  end

  def print_format_logger
    log_info = "#{request.request_method} #{request.path} for #{request.ip} at #{Time.now.to_s}"
    log_info << "\nParameters:\n #{@params.to_s}"
    log_info << "\nRequest:\n #{@request_body}" unless @request_body.empty?
    puts log_info
    logger.info log_info
  end

  def request_body(body = request.body)
    case body
    when StringIO then body.string
    when Tempfile then body.read
    # gem#passenger is ugly!
    #     it will change the structure of REQUEST
    #     detail at: https://github.com/phusion/passenger/blob/master/lib/phusion_passenger/utils/tee_input.rb
    when (defined?(PhusionPassenger) and PhusionPassenger::Utils::TeeInput)
      body.read
    # gem#unicorn
    #     it also change the strtucture of REQUEST
    when (defined?(Unicorn) and Unicorn::TeeInput)
      body.read
    when Rack::Lint::InputWrapper
      body.read
    else
      body.to_str
    end.force_encoding("UTF-8")
  end

  def md5_key(str)
    Digest::MD5.hexdigest(str)
  end

  def respond_with_json hash, code = nil
    raise "code is necessary!" unless hash.has_key?(:code)
    content_type "application/json"
    body   hash.to_json
    status code || 200
  end

  # 404 page
  not_found do
    haml :"shared/not_found", layout: :"layouts/layout", views: ENV["VIEW_PATH"]
  end
end
