module ApplicationHelper

  # flash#success/warning/danger message will show
  # when redirect between action
  def flash_message
    return if !defined?(flash)
    return if flash.empty?
    # hash key must be symbol
    hash = flash.inject({}) { |h, (k, v)| h[k.to_s] = v; h; }
    # bootstrap#v3 [alert] javascript plugin
    flash.keys.map(&:to_s).grep(/warning|danger|success/).map do |key|
      close = link_to("&times;", "#", class: "close", "data-dismiss" => "alert")
      tag(:div, {content: "#{close}#{hash[key]}", class: "alert alert-#{key}", role: "alert" }) 
    end.join
  end

  MOBILE_USER_AGENTS =  'palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                        'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                        'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                        'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                        'webos|amoi|novarra|cdm|alcatel|pocket|iphone|mobileexplorer|mobile'
  # check remote client whether is mobile
  # define different layout
  def mobile?
    user_agent = request.user_agent.to_s.downcase rescue "false"
    return false if user_agent =~ /ipad/
    user_agent =~ Regexp.new(MOBILE_USER_AGENTS)
  end

  # generate keywords from obj
  # for js search function
  def keywords(obj)
    dirty_words = %w[ip browser created_at updated_at id]
    obj.class.properties.map(&:name)
      .reject { |v| dirty_words.include?(v.to_s) }
      .map { |var| obj.instance_variable_get("@%s" % var).to_s }
      .join(" ")
  end
end
