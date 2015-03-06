#encoding: utf-8 
class API::EntityController < API::ApplicationController

  # /api/entity
  route :get, :post, "/" do
    campaign = Campaign.first(token: params[:token] || "noset")
    datas = params["data"] || []

    if campaign
      unless datas.empty?
        @column_mapping = campaign.column_mapping
        save_successfully = datas.map do |data|
          entity_params = campaign.entity_params(data, @column_mapping)
          entity = campaign.entities.new(entity_params)
          entity.save_with_logger
        end.find_all { |state| state }.count

        hash = { code: 1, info: "create %d entities." % save_successfully }
        respond_with_json hash, 200
      else
        hash = { code: 1, info: "data is empty" }
        respond_with_json hash, 200
      end
    else
      hash = { code: 0, info: "token not valid" }
      respond_with_json hash, 200
    end

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
