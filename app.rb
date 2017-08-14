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
  @posts = Post.all.last(10).sort_by { |r| r.id }.reverse
  erb :index
end

post '/posts' do
  user = User.find_by_id(session[:user_id])
  post = user.posts.new(params[:post])
  if post.save && user.save
    redirect "/posts/#{post.id}"
  else
    redirect '/posts/new'
  end
end

get '/posts/new' do
  erb :"posts/new"
end

get '/posts/:id' do
  @post = Post.find_by_id(params[:id])
  @user = @post.user
  erb :"posts/show"
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
  erb :"posts/edit"
end

get '/signup' do
  erb :"users/signup"
end

post '/signup' do
  user = User.find_by(username: params[:user][:username])
  if user
    flash[:alert] = "Sorry, that username is taken."
    redirect "/signup"
  elsif params[:user][:username].length < 5 || params[:user][:password].length < 5
    flash[:alert] = "Your username and password must be longer than 5 characters."
    redirect "/signup"
  else
     user = User.create(params[:user])
     session[:user_id] = user.id
     flash[:alert] = "Congrats, you're signed up!"
     redirect "/users/#{user.id}"
  end
  erb "Params: #{params.inspect}"
end

get '/login' do
  erb :"users/login"
end

post '/login' do
  user = User.find_by(username: params[:user][:username])
  if user && user.password == params[:user][:password]
    session[:user_id] = user.id
    flash[:alert] = "Successfully logged in."
    redirect "/"
  else
    flash[:alert] = "Failed to log in."
    redirect '/login'
  end
  erb "Params: #{params.inspect}"
end

get '/users/:id' do
  @post = Post.find_by_id(params[:id])
  @user = User.find(params[:id])
  @posts = @user.posts.sort_by { |r| r.id }.reverse
  erb :"users/show"
end

put '/users/:id' do
  user = User.find_by_id(params[:id])
  if user.update(params[:user])
    redirect "/users/#{user.id}"
  else
    redirect "/users/#{user.id}/edit"
  end
  erb :"users/show"
end

get '/users/:id/edit' do
  @user = User.find_by_id(params[:id])
  erb :"users/edit"
end

get "/users/:id/delete" do
	user = User.find_by_id(params[:id])
	user.destroy
	redirect "/"
end

get '/logout' do
  session.clear
  flash[:alert] = "Goodbye!"
  redirect '/'
end
