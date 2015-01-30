#encoding: utf-8
module Cpanel; end
class Cpanel::ApplicationController < ApplicationController 
  helpers CpanelHelper

  before do
    unless current_user
      flash[:warnging] = "please login."
      redirect "/"
    end
  end
end
