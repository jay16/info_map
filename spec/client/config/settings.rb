#encoding: utf-8
class Settings < Settingslogic
    source "%s/config/settings.yaml" % ENV["APP_ROOT_PATH"]
    namespace  ENV["RACK_ENV"] 
end
