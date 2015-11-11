require 'rubygems'
require 'sinatra'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'qwertyuiopasdfghjklzxcvbnm' 


get '/' do
  erb :test
end

get '/nested' do
  erb :"nested/nested_template"
end