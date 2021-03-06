require './config/environment'
require 'pry'
class ApplicationController < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
  end

  configure do
    enable :sessions
    set :session_secret, 'twitter_secret'

    set :public_folder, 'public'
    set :views, 'app/views'
  end

  helpers do
     def logged_in?
      !!current_user    #well always yeild false
    end
     def current_user
      @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    end
    end

  use Rack::Flash

  get '/' do
    if logged_in?
      redirect to '/tweets'
    else
      erb :index
    end
  end

  get '/signup' do
    if !logged_in?
      erb :'users/create_users'
    else
      redirect to '/tweets'
    end
  end

  post '/signup' do
    new_user = User.new(username: params[:username], email: params[:email], password: params[:password])

    if new_user.save
      session[:user_id] = new_user.id
      redirect to '/tweets'
    else
      flash[:message] = 'All fields are required!'
      redirect to '/signup'
    end
  end

  get '/logout' do
    if logged_in?
      session.clear
      redirect to '/login'
    else
      redirect to '/login'
    end
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find_by_id(session[:user_id])
    end
  end
end
