#encoding: utf-8
@app_routes_map = {
  "/"       => "HomeController",
  "/users"  => "UsersController",
  "/cpanel" => "Cpanel::HomeController",
  "/cpanel/users"     => "Cpanel::UsersController",
  "/cpanel/campaigns" => "Cpanel::CampaignsController"
}

require "./config/boot.rb"

@app_routes_map.each_pair do |path, mod|
  clazz = mod.split("::").inject(Object) {|o,c| o.const_get c}
  map(path) { run clazz }
end
