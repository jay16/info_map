#encoding: utf-8
require 'rest_client'

def parse_mailgate_log(line)
  regexp = /\[(.*?)\]\s+\[(.*?)\] Mail\.RR\s(.*?\s*->\s*.*?)\s\((.*?)\)\[(.*)\]\[(.*?)\]\[(.*?)\]\[(.*?)\]/
  line  = line.force_encoding("UTF-8")
  match = line.scan(regexp) rescue [nil]

  if match[0] and match[0].size == 8
    timestamp, emailfile, from_to, subject, result, mgham, mgtaglog, charset = match[0]
    from, to = from_to.split(/->/).map { |str| str.gsub(/<|>/, "").strip } rescue ["", ""]

    from = from.scan(/.*?_(\d+)_0@(.*)/)[0].join("/") rescue from if from
    to   = to.scan(/.*?_(\d+)_0@(.*)/)[0].join("/") rescue to if to
    if subject.start_with?("Returned Mail:")
      result  = result + "<br>subject: " + subject
      subject = subject.scan(/(Returned\sMail\:\s\w+)/)[0][0]
    elsif subject.start_with?("Warning--")
      result  = result + "<br>subject: " + subject
      subject = "Warning#Mailgates"
    end
    return {timestamp: timestamp.split.last, emailfile: emailfile, from: from, to: to,
     subject: subject, result: result, mgham: mgham, mgtaglog: mgtaglog, charset: charset}
  else
    return {raw: line}
  end
end

filepath = "./mgmailerd.log"
token    = "c6f3e63b59d76848a1ee61b578bcde3a"
url      = "http://localhost:3000/api/entity"

datas = IO.readlines(filepath).map do |line|
  hash = parse_mailgate_log(line)
end.reverse
datas.reject! { |hash| hash.keys.include?(:raw) }
params = {
  :token => token,
  :data  => datas
}
response = RestClient.post url, params.to_json, :content_type => :json, :accept => :json
puts response.inspect
