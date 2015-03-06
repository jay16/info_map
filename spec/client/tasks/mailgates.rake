#encoding: utf-8
namespace :mailgates do
  desc "mailgates log parser"
  task :logger => :environment do
    base     = @settings.base
    task     = @settings.tasks.log_parser
    filepath = task.filepath
    url      = base.url + task.campaign.path 

    tmp_path = "%s/tmp/latest_count" % ENV["APP_ROOT_PATH"]
    latest_count = IO.read(tmp_path).to_i rescue 0
    lines = IO.readlines(filepath).uniq
    current_count = lines.length
    datas = lines[latest_count..-1].map { |line|
      hash = Mailgates::Log.parser(line)
    }.reverse
    datas.reject! { |hash| hash.keys.include?(:raw) }

    params = { :token => task.campaign.token, :data  => datas }
    response = RestClient.post url, params.to_json, :content_type => :json, :accept => :json
    hash = JSON.parse(response) rescue { code: -1 , info: "local error" }
    if hash["code"] == 1
      puts hash["info"]
      system("echo %d > %s" % [current_count, tmp_path])
    end
  end
end
