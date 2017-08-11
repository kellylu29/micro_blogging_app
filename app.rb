require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require './models'

set :database, {adapter: "sqlite3", database: "micro_blogging_app.sqlite3"}

enable :sessions

def current_user
  @current_user ||= User.find_by_id(session[:user_id])
end

get '/' do
  @posts = Post.all.sort_by { |r| r.id }.reverse
  erb :index
end

post '/posts' do
  post = Post.new(params[:post])
  if post.save
    redirect "/posts/#{post.id}"
  else
    redirect '/posts/new'
  end
end

get '/posts/new' do
  erb :new
end

get '/posts/:id' do
  @post = Post.find_by_id(params[:id])
  erb :show
end

put '/posts/:id' do
  post = Post.find_by_id(params[:id])
  if post.update(params[:post])
    redirect "/posts/#{post.id}"
  else
    redirect "/posts/#{post.id}/edit"
  end
end

get '/posts/:id/edit' do
  @post = Post.find_by_id(params[:id])
  erb :edit
end

get '/signup' do
  erb :signup
end

post '/signup' do
  user = User.find_by(username: params[:user][:username])
  if user
    flash[:alert] = "That username is taken."
    redirect "/signup"
  elsif params[:user][:username].length < 2 || params[:user][:password].length < 2
    flash[:alert] = "Your username and password must be longer than 2 characters."
    redirect "/signup"
  else
     user = User.create(params[:user])
     session[:user_id] = user.id
     flash[:alert] = "Yay you're signed up!"
     redirect "/users/#{user.id}"
  end
  erb "Params: #{params.inspect}"
end

get '/login' do
  erb :login
end

post '/login' do
  user = User.find_by(username: params[:user][:username])
  if user && user.password == params[:user][:password]
    session[:user_id] = user.id
    flash[:alert] = "Successfully, logged in."
    redirect "/users/#{user.id}"
  else
    flash[:alert] = "Failed to log in."
    redirect '/login'
  end
  erb "Params: #{params.inspect}"
end

get '/users/:id' do

  if current_user.id == params[:id]
    erb :showuser
  else
    flash[:alert] = "Sorry wrong credentials"
  end
  erb :showuser
end

get '/users/:id/edit' do
  @user = User.find_by_id(params[:id])
  erb :edit
end

get "/users/:id/delete" do
	user = User.find_by_id(params[:id])
	user.destroy
	redirect "/"
end	

get '/logout' do
  session.clear
  flash[:alert] = "Bye!"
  redirect '/'
end
