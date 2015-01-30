#encoding: utf-8
class Cpanel::CampaignsController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/campaigns"
  set :layout, :"../layouts/layout"

  get "/" do
    haml :index, layout: settings.layout
  end

  get "/new" do
    @campaign = current_user.campaigns.new


    haml :new, layout: settings.layout
  end

end
