require "sinatra/base"

class BankController < Sinatra::Base
  get "/" do
    haml :login
  end

  get "/:account" do
    haml :account
  end
end
