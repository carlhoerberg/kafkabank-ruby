require "bundler/setup"
require "./bank"

map "/" do
  run BankController
end
