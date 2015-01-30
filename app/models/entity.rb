#encoding: utf-8
require "model-base"
class Entity
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id, Serial 
    (1..::Setting.campaign.colnum.maximum || 32).each do |i| 
      property "column#{i}".to_sym, String 
    end

    belongs_to :campaign, required: false
end
