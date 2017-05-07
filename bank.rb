require "sinatra/base"
require "excon"
require "json"

class BankController < Sinatra::Base
  get "/" do
    haml :login
  end

  post "/" do
    redirect "/#{params[:account]}"
  end

  get "/:account" do |account|
    #resp = Excon.get "https://localhost:8080/balance/#{account}"
    #data = JSON.parse resp.body
    #@balance = data["balance"]
    haml :account
  end
end
