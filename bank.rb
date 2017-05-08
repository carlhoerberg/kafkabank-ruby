require "sinatra/base"
require "excon"
require "json"
require "kafka"

# Create an array with the broker host names.

class BankController < Sinatra::Base
  BACKEND = ENV.fetch("BACKEND", "http://localhost:3000")
  BROKERS = ENV['CLOUDKARAFKA_BROKERS'].split(',')
  TOPIC_PREFIX = ENV['CLOUDKARAFKA_TOPIC_PREFIX']

  configure do
    K = Kafka.new(
      seed_brokers: BROKERS,
      ssl_ca_cert: ENV['CLOUDKARAFKA_CA'],
      ssl_client_cert: ENV['CLOUDKARAFKA_CERT'],
      ssl_client_cert_key: ENV['CLOUDKARAFKA_PRIVATE_KEY'],
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
    @balance = balance(account)
    haml :account
  end

  post "/:account/send" do |account|
    msg = {
      sender: account,
      receiver: params[:receiver],
      amount: params[:amount].to_f,
      message: params[:message]
    }
    K.deliver_message(msg.to_json, topic: "#{TOPIC_PREFIX}transactions")
    redirect "/#{account}"
  end

  helpers do
    def balance(account)
      resp = Excon.get "#{BACKEND}/balance/#{account}"
      data = JSON.parse resp.body
      data["balance"]
    rescue Excon::Error => e
      puts e.inspect
      "Balance unknown"
    end
  end
end
