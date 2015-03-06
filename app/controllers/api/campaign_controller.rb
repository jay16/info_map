#encoding: utf-8 
class API::CampaignController < API::ApplicationController

  # /api/entity
  route :get, :post, "/" do
    token = params[:token] || "noset"
    campaign = Campaign.first(token: token)

    if campaign
      hash = { code: 1, info: "see detail with params", params: campaign.to_params }
      respond_with_json hash, 200
    else
      hash = { code: 0, info: "token[%s] is not valid" % token }
      respond_with_json hash, 204
    end
  end

  route :get, :post, "/data" do
    token = params[:token] || "noset"
    campaign = Campaign.first(token: token)

    if campaign
      hash = { code: 1, info: "see detail with data", data: campaign.entities.to_a }
      respond_with_json hash, 200
    else
      hash = { code: 0, info: "token[%s] is not valid" % token }
      respond_with_json hash, 204
    end
  end
end
