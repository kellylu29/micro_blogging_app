require 'sinatra'
require 'sinatra/activerecord'
require './models'

set :database, {adapter: "sqlite3", database: "micro_blogging_app.sqlite3"}