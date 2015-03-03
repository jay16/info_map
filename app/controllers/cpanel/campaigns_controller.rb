#encoding: utf-8
class Cpanel::CampaignsController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/campaigns"
  set :layout, :"../layouts/layout"
  include WillPaginate::Sinatra::Helpers

  get "/" do
    @campaigns = current_user.campaigns.paginate(:page => params[:page], :per_page => 30)

    haml :index, layout: settings.layout
  end

  get "/:id/entities" do
    @campaign = current_user.campaigns.first(id: params[:id])
    @entities = @campaign.entities.paginate(:page => params[:page], :per_page => 30)

    haml :entities, layout: settings.layout
  end

  get "/new" do
    @campaign = current_user.campaigns.new

    haml :new, layout: settings.layout
  end

  # Post /cpanel/campaigns
  post "/" do
    @campaign = current_user.campaigns.new(params[:campaign])
    @campaign.token = md5_key("%d-%s" % [current_user.id, Time.now.to_s])
    @campaign.save_with_logger

    redirect "/cpanel/campaigns/%d" % @campaign.id
  end

  get "/:id" do
    @campaign = current_user.campaigns.first(id: params[:id])

    haml :show, layout: settings.layout
  end

  # Get /cpanel/campaign/:id
  get "/:id/edit" do
    @campaign = ChangeLog.first(id: params[:id])

    haml :edit, layout: settings.layout
  end

  # Post /cpanel/campaign/:id
  post "/:id" do
    @campaign = ChangeLog.first(id: params[:id])
    source = @campaign.source
    unless @campaign.source.split(/\s+/).include?("web")
      source += " web"
    end
    campaign_params = params[:campaign].merge({ 
      editor: "%s#%d" % [current_user.name, current_user.id],
      source: source
    })
    @campaign.update(campaign_params)

    redirect "/cpanel/campaign/%d" % @campaign.id
  end
end
