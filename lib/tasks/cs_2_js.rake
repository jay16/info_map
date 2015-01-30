#encoding:utf-8
desc "tasks around CoffeeScript"
namespace :cs2js do

  def lasttime(info, &block)
     bint = Time.now.to_f
     yield
     eint = Time.now.to_f
     printf("%-10s - %s\n", "[%dms]" % ((eint - bint)*1000).to_i, info)
  end
  desc "CoffeeScript Complie file to JS file"
  task :compile => :environment do
     assets_path       = "%s/%s" % [ENV["APP_ROOT_PATH"],"app/assets"]
     javascript_path   = "%s/javascripts" % assets_path
     coffeescript_path = "%s/coffeescripts" % assets_path
     coffeescripts = Dir.entries(coffeescript_path).select { |cs| cs if cs =~ /.*?\.coffee$/ }
     coffeescripts.each do |coffeescript_file|
       lasttime "%-25s - CoffeScript file Complie over." % coffeescript_file do 
         file_path   = File.join(coffeescript_path,coffeescript_file)
         target_path = File.join(javascript_path, File.basename(coffeescript_file.sub(".coffee", ".js")))
         File.open(target_path, "w:utf-8") do |file|
           file.puts CoffeeScript.compile(File.read(file_path))
         end
       end
     end if !coffeescripts.empty?
     sass_path = "%s/sass" % assets_path
     css_path  = "%s/stylesheets" % assets_path
     sass_files = Dir.entries(sass_path).select { |cs| cs if cs =~ /.*?\.scss$/ }
     sass_files.each do |sass_file|
       lasttime "%-25s - Scss file Complie over." % sass_file do 
         file_path   = File.join(sass_path, sass_file)
         target_path = File.join(css_path, File.basename(sass_file).sub(".scss", ".css"))
         File.open(target_path, "w:utf-8") do |file|
           engine = Sass::Engine.new(File.read(file_path), :syntax => :scss)
           file.puts engine.render
         end
       end
     end
  end
end
