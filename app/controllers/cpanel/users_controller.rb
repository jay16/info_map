#encoding: utf-8
class Cpanel::UsersController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/users"
  set :layout, :"../layouts/layout"

  get "/" do
    haml :index, layout: settings.layout
  end

end
