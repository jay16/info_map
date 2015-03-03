#encoding: utf-8
require "model-base"
class Campaign
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id,       Serial 
    property :name,     String, :required => true 
    property :desc,     String
    property :token,    String
    property :colnum,   Integer, :default => 1 # column quantity
    (1..::Setting.campaign.colnum.maximum || 32).each do |index| 
      property "column#{index}".to_sym, String
    end

    has n, :entities
    has n, :constraints
    belongs_to :user, requried: false

    def entity_params(params)
      (1..self.colnum).inject({}) do |param, i|
        colalias = self.instance_variable_get("@column%d" % i)
        value = params.find { |k, p| k.to_s == colalias }[1]
        param.merge!({ "#{colname}" => CGI.unescape(value) })
      end
    end

    def human_name
      "活动"
    end
end
