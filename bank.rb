require "sinatra/base"
require "excon"
require "json"
require "kafka"

class BankController < Sinatra::Base
  configure do
    K = Kafka.new(
      seed_brokers: ["localhost:9092"],
      client_id: "kafkabank-ruby",
    )
  end

  get "/" do
    haml :index
  end

  post "/" do
    redirect "/#{params[:account]}"
  end

  get "/:account" do |account|
    @account = account
    @balance = balance
    #Kafka.stream_messages("balance") do
    #  next if msg[:account] != @account
    #  @balance = msg[:balance]
    #end
    #@balance = 1234
    haml :account
  end

  post "/:account/send" do |account|
    msg = {
      sender: account,
      receiver: params[:receiver],
      amount: params[:amount].to_f,
      message: params[:message]
    }
    K.deliver_message(msg.to_json, topic: "transactions")
    redirect "/#{account}"
  end

  helpers do
    def balance
      resp = Excon.get "https://localhost:3000/balance/#{account}"
      data = JSON.parse resp.body
      data["balance"]
    rescue
      "Balance unknown"
    end
  end
end
