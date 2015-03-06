#encoding: utf-8
require 'rest_client'

token = "c6f3e63b59d76848a1ee61b578bcde3a"
params = { token: token }
response = RestClient.post "http://localhost:3000/api/campaign", params.to_json, :content_type => :json, :accept => :json
puts response.inspect
