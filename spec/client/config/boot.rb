require "rubygems"

ENV["RACK_ENV"]  ||= "development"

begin
  ENV["BUNDLE_GEMFILE"] ||= "%s/Gemfile" % ENV["APP_ROOT_PATH"]
  require "rake"
  require "bundler"
  Bundler.setup
rescue => e
  puts e.backtrace &&  exit
end
Bundler.require(:default, ENV["RACK_ENV"])

