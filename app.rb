require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/json'
require './models.rb'
require 'open-uri'

use Rack::Session::Cookie

def get_description html
  description = html.css('meta[property="og:description"]')[0]
  if description
    return description.attr('content')
  else
    description = html.css('meta[name="description"]')[0]
    if description
      description.text
    else
      ''
    end
  end
end

def get_image html
  image = html.css('meta[property="og:image"]')[0]
  if image
    image.attr('content')
  else
    ''
  end
end

def set_items
  user = User.find(session[:user_id])
  user.items
end

get '/' do
  unless session[:user_id]
    redirect "/sign_in"
  end
  @user = User.find(session[:user_id])
  @items = set_items
  erb :index
end

get '/favorites' do
  @user = User.find(session[:user_id])
  @items = set_items.where(favorite: true)
  erb :index
end

get '/tag/:id' do
  @user = User.find(session[:user_id])
  @items = set_items.where(tag_id: params[:id])
  erb :index
end

post '/create' do
  html = Nokogiri::HTML(open(params[:url]))
  title = html.css('title')[0].text
  description = get_description html
  image = get_image html
  Item.create(url: params[:url], title: title, description: description, image: image, user_id: params[:user_id])
  redirect '/'
end

get '/tag/list' do
  Tag.where("name LIKE ?", "%#{params[:term]}%").pluck(:name).to_json
end

post '/tag/create' do
  item = Item.find(params[:id])
  tag = Tag.where(name: params[:tag]).first
  if tag.present?
    item.tag = tag
    item.save
  else
    tag = Tag.create(name: params[:tag])
    item.tag = tag
    item.save
  end
  redirect '/'
end

post '/favorite' do
  item = Item.find(params[:id])
  if item.favorite
    item.update(favorite: false)
  else
    item.update(favorite: true)
  end
  json favorite: item.favorite
end

post '/delete' do
  item = Item.find(params[:id])
  item.destroy
  redirect '/'
end

get '/app.css' do
  scss :'scss/app'
end

get '/sign_in' do
  erb :sign_in
end

get '/sign_up' do
  erb :sign_up
end

post '/user/create' do
  User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
  redirect "/"
end

post '/session/create' do
  user = User.find_by_name(params[:name])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
  end
  redirect "/"
end
