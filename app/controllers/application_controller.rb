#encoding: utf-8
require "json"
require 'digest/md5'
require "sinatra/multi_route"
class ApplicationController < Sinatra::Base
  # css/js/view配置文档
  use AssetHandler
  use ImageHandler
  use SassHandler
  use CoffeeHandler

  helpers ApplicationHelper
  helpers HomeHelper
  
  register Sinatra::Reloader if development? or test?
  register Sinatra::MultiRoute
  register Sinatra::Flash
  register SinatraMore::MarkupPlugin

  before do
    @request_body = request_body || ""
    request_hash = JSON.parse(@request_body) rescue {}
    @params = params.merge(request_hash)
    @params = @params.merge({ip: remote_ip, browser: remote_browser})

    print_format_logger
  end

  def remote_ip
    request.ip 
  end
  def remote_path
    request.path 
  end
  def remote_browser
    request.user_agent
  end

  # execute linux shell command
  # return array with command result
  # [execute status, execute result] 
  def run_command(shell, whether_show_log=true, whether_reject_empty=true)
    result = IO.popen(shell) do |stdout| 
        stdout.readlines#.reject(&method) 
    end.map { |l| l.is_a?(String) ? string_format(l) : l }
    status = $?.exitstatus.zero?
    if !status or whether_show_log
      shell  = string_format(shell).split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
      result = ["bash: no output"] if result.empty?
      if result.length > 100
        resstr = "\t\tbash: output line number more than 100 rows."
      else
        resstr = result.map { |line| "\t\t" + line }.join
      end
      puts "%s\n\t\t==> %s\n%s\n" % [shell, status, resstr]
    end
    return result.unshift(status)
  end 

  def string_format(str)
    str.gsub(ENV["APP_ROOT_PATH"], "!~")
  end

  def print_format_logger
    log_info = "#{request.request_method} #{request.path} for #{request.ip} at #{Time.now.to_s}"
    log_info << "\nParameters:\n #{@params.to_s}"
    log_info << "\nRequest:\n #{@request_body }" unless @request_body.empty?
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
    end
  end

  def respond_with_json hash, code = nil, whether_perfect = true
    hash.perfect! if whether_perfect
    raise "code is necessary!" unless hash.has_key?(:code)
    content_type "application/json"
    body   hash.to_json
    status code || 200
  end

  def md5_key(str)
    Digest::MD5.hexdigest(str)
  end

  def current_user
    @current_user ||= User.first(email: request.cookies["cookie_user_login_state"] || "")
  end

  #alias_method :respond_to_api, :respond_with_json

  # 404 page
  not_found do
    haml :"shared/not_found", layout: :"layouts/layout", views: ENV["VIEW_PATH"]
  end
end
