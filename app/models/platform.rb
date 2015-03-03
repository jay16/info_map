#encoding: utf-8
require "model-base"
class Platform
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id,       Serial 
    property :name,     String, :required => true 
    property :os,     String
    property :hostname,    String
    property :bite,   Integer, :default => 1 # column quantity

    def human_name
      "活动"
    end
end
