#encoding: utf-8
desc "generate basic tables"
task :tables => :environment do

  filepath = "%s/config/tables.yaml" % @options[:app_root_path]
  yaml = YAML.load_file(filepath)
  meminfo = yaml["tables"]["meminfo"]
  user = User.first(id: 1)
  puts user

end

