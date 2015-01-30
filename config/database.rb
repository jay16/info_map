require "date"

# make sure /db folder exist
root_path = ENV["APP_ROOT_PATH"]
db_path   = File.join(root_path, "db")
FileUtils.mkdir_p(db_path) unless File.exist?(db_path)

# configure database connection
configure do
  db_name = "%s_%s" % [ENV["APP_NAME"], ENV["RACK_ENV"]]
  db_path = "%s/db/%s.db" % [root_path, db_name]
  DataMapper::setup(:default, "sqlite3://%s" % db_path)

  # 加载所有models
  require "lib/utils/data_mapper/model.rb"
  recursion_require("app/models", /\.rb$/, root_path)

  # 自动迁移数据库
  DataMapper.finalize.auto_upgrade!
  #DataMapper.finalize.auto_migrate!

  #启动后保证db文件有被读写权限
  system("chmod 777 %s/db/*.db" % root_path)
end

