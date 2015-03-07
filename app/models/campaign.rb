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
    (1..::Settings.campaign.colnum.maximum || 32).each do |index| 
      property "column#{index}".to_sym, String
    end

    has n, :entities
    has n, :constraints
    belongs_to :user, requried: false

    def to_params
      params = { name: name, desc: desc , token: token , colnum: colnum }
      params[:columns] = (1..colnum).map { |i| instance_variable_get("@column%d" % i) }
      return params
    end

    def column_mapping
      (1..self.colnum).inject({}) do |param, i|
        colname = "column%d" % i
        colalias = self.instance_variable_get("@"+colname)
        param.merge!({ "#{colalias}" => "#{colname}" })
      end
    end

    # params for creating entity
    def entity_params(params, column_mapping = self.column_mapping)
      new_params = {}
      params.each_pair do |key, value|
        new_params[column_mapping[key]] = value
      end
      return new_params
    end

    def human_name
      "活动"
    end
end
