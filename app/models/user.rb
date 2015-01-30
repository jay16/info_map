#encoding: utf-8
require "model-base"
class User
    include DataMapper::Resource
    include Utils::DataMapper::Model
    extend  Utils::DataMapper::Model
    include Utils::ActionLogger

    property :id        , Serial 
    property :email     , String  , :required => true, :unique => true
    property :name      , String
    property :password  , String  , :required => true
    property :gender    , Boolean 
    property :country   , String  
    property :province  , String
    property :city      , String  

    has n, :campaigns
    has n, :constraints, through: :campaigns

    after :create do |obj|
      # name default from email
      update(name: email.split(/@/).first) if name.nil? 
    end

    def admin?
      ::Setting.admins.split(/;/).include?(self.email)
    end

    # instance methods
    def human_name
      "用户"
    end
end
