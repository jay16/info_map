#encoding: utf-8 
class API::EntityController < API::ApplicationController

  # /api/entity
  route :get, :post, "/" do
    puts params
    puts "*"*10
    puts request.body.read.class
    #campaign = Campaign.first(token: params[:token] || "noset")
    #datas = params["data"] || []
    #if campaign and not datasempty?
    #  save_successfully = datas.map do |data|
    #    campaign.entities.new(campaign.entity_params(data)).save
    #  end.find_all { |state| state }.count

    #  hash = { code: 1, info: "create %d entities." % save_successfully }
    #  respond_with_json hash, 200
    #else
    #  hash = { code: 0, info: "token not valid or data is empty" }
    #  respond_with_json hash, 204
    #end

  end

  route :get, :post, "/data" do
    device = Device.first_or_create(uid: params[:uid] || "error_uid")
    json = JSON.parse(params[:data])
    device_data = device.device_datas.new({
      :input  => json["input"],
      :remain => json["szRemain"],
      :type   => json["szType"],
      :money  => json["nMoney"],
      :time   => json["nTime"],
      :simulator => device.simulator
    })
    if device_data.save_with_logger
      hash = { code: 1, info: device_data.id }
      respond_with_json hash, 200
    else
      hash = { code: 0, info: "error", error: device_data.errors.inspect.to_s }
      respond_with_json hash, 401
    end
  end
end
