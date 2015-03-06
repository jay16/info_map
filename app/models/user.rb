#encoding: utf-8
require "model-base"
require 'digest/md5'
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
    property :uid       , String  , :required => true, :unique => true
    property :last_sign_in_ip    , String
    property :current_sign_in_ip , String
    property :last_sign_in_at    , DateTime, :default => DateTime.now
    property :current_sign_in_at , DateTime, :default => DateTime.now
    property :sign_in_count      , Integer , :default => 0

    has n, :campaigns
    has n, :constraints, through: :campaigns

    after :create do |obj|
      # name default from email
      update(name: email.split(/@/).first) if name.nil? 
    end

    def admin?
      ::Setting.admins.split(/;/).include?(self.email)
    end

    def sign_in_event(ip)
      update({ :last_sign_in_at => current_sign_in_at, :last_sign_in_ip => current_sign_in_ip })
      update({ :current_sign_in_at => DateTime.now, :current_sign_in_ip => ip, :sign_in_count => sign_in_count + 1 })
    end

    # instance methods
    def human_name
      "用户"
    end
end
