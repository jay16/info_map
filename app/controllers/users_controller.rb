#encoding: utf-8 
class UsersController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/users"
  set :layout, :"../layouts/layout"

  get "/" do
    redirect "/users/login" unless current_user
    redirect "/cpanel" if current_user and current_user.admin?

    haml :index, layout: settings.layout
  end

  # GET /users/login
  get "/login" do
    @user ||= User.new
    @user.email = request.cookies["_email"]

    haml :login, layout: settings.layout
  end

  # POST login /users/login
  post "/login" do
    user = User.first(email: params[:user][:email])
    if user and user.password == md5_key(params[:user][:password])
      response.set_cookie "cookie_user_login_state", {:value=> user.email, :path => "/", :max_age => "2592000"}
      user.sign_in_event(remote_ip)

      flash[:success] = "登陆成功"
      redirect request.cookies["cookie_before_login_path"] || "/users"
    else
      response.set_cookie "cookie_user_login_state", {:value=> "", :path => "/", :max_age => "2592000"}
      response.set_cookie "_email", {:value=> params[:user][:email], :path => "/", :max_age => "2592000"}

      flash[:warning] = "登陆失败:" + (user ? "密码错误": "用户不存在")
      redirect "/users/login"
    end
  end

  # GET /users/register
  get "/register" do
    @user ||= User.new

    haml :register, layout: :"../layouts/layout"
  end

  # post /user/register
  post "/register" do
    user_params = params[:user]
    user_params.delete(:confirm_password)
    user_params.delete("confirm_password")
    user_params[:password] = md5_key(user_params[:password])
    user = User.new(user_params)
    user.uid = md5_key(user.email)

    if user.save
      response.set_cookie "_email", {:value=> user.email, :path => "/", :max_age => "2592000"}
      user.sign_in_event(remote_ip)
      flash[:success] = "注册成功，请登陆."

      redirect "/users/login"
    else
      msg = ["注册失败:"]
      format_dv_errors(user).each_with_index do |hash, index|
        msg.push("%d. %s" % [index+1, hash.to_a.join(": ")])
      end
      flash[:danger] = msg.join("<br>")
      redirect "/user/register"
    end
  end

  # logout
  # delete /user/logout
  get "/logout" do
    response.set_cookie "cookie_user_login_state", {:value=> "", :path => "/", :max_age => "2592000"}
    redirect "/"
  end

  # post /user/check_email_exist
  post "/check_email_exist" do
    email = params[:user][:email] rescue "notset"
    user = User.first(email: email)
    hash = { valid:  user.nil?, code: 200 }
    respond_with_json hash, 200
  end
end
