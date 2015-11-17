require 'rubygems'
require 'sinatra'
require 'pry'

use Rack::Session::Cookie, :key => 'rack.session',
                           :path => '/',
                           :secret => 'qwertyuiopasdfghjklzxcvbnm' 


helpers do
  def card_path(card)
    jpg_name = card[1] + "_" + card[0] + ".jpg"
  end
  
  def card_value(card)
    card_value = 0
    if value_and_suit = /(\d+)/.match(card[0])
      card_value = value_and_suit[0].to_i
    elsif value_and_suit = /(jack|queen|king)/.match(card[0])
      card_value = 10
    elsif value_and_suit = /(ace)/.match(card[0])
      card_value = 11
    end
    card_value
  end
  
  def hand_total(hand)
    total = 0
    hand.each do |card|
      total = total + card_value(card)
    end

    ace_array = hand.select {|card| /ace/.match(card[0])}.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end
end

before do
  @show_hit_stay_buttons = true
end


get '/' do
  unless session[:username]
    redirect to('/user')
  end
  
  redirect to('/game')
end

get '/nested' do
  erb :"nested/nested_template"
end

get '/game' do
  RANKS = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king', 'ace']  
  SUITS = ['hearts', 'spades', 'clubs', 'diamonds']
  session[:deck] = []
  session[:dealer_hand] = []
  session[:player_hand] = []

  session[:deck] = RANKS.product(SUITS)
  session[:deck].shuffle!
    # binding.pry
  
  2.times do
    session[:dealer_hand] << session[:deck].pop
    session[:player_hand] << session[:deck].pop
   end
  
  session[:player_total] = hand_total(session[:player_hand])
  session[:dealer_total] = hand_total(session[:dealer_hand])

  if hand_total(session[:player_hand]) == 21
    @show_hit_stay_buttons = false
  elsif hand_total(session[:dealer_hand]) == 21
    @show_hit_stay_buttons = false
    @error = "sorry, dealer has blackjack"
  end
    

  erb :game
end

get '/logout' do
  session.clear
  redirect to('/')
end

get '/user' do
  erb :user
end

post '/user' do
  session[:username] = params[:username]
  redirect to('/')
end

post '/game/player/hit' do
  if hand_total(session[:player_hand]) < 21
    session[:player_hand] << session[:deck].pop
  end
  if hand_total(session[:player_hand]) > 21
    @error = "You busted, dealer wins"
    @show_hit_stay_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
  @show_hit_stay_buttons = false
  erb :game
end
