#encoding: utf-8
module StringMethods
  def self.included(base)
    base.class_eval do
      [:process_pattern].each do |method_name|
        next unless method_defined?(method_name)
        location = self.method(method_name).source_location rescue next
        next if location[0] == __FILE__

        warn "\tRemove Method - #{method_name} defiend in:\n\t%s\n\tand reload file in \n\t%s" % [location, __FILE__]
        remove_method method_name
      end
    end
  end

  def process_pattern
    unless ENV["APP_ROOT_PATH"]
      puts "\nWARNGING: ENV['APP_ROOT_PATH'] undefined!\n"
    end
    cmd = "%s/lib/utils/processPattern/processPattern '%s'" % [ENV["APP_ROOT_PATH"], self]

    result = IO.popen(cmd) do |stdout| 
        stdout.readlines#.reject(&method) 
    end
    status = $?.exitstatus.zero?

    shell  = cmd.split(/\n/).map { |line| "\t`" + line + "`" }.join("\n")
    result = ["bash: no output"] if result.empty?
    resstr = result.map { |line| "\t\t" + line }.join
    puts "%s\n\t\t==> %s\n%s\n" % [shell, status, resstr]

    return result.unshift(status)
  end
end
class String
  include StringMethods
end
