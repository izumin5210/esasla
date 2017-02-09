require 'sinatra'
require 'sinatra/reloader' if development?

def esa_client
  @client = Esa::Client.new(
    access_token: ENV['ESA_ACCESS_TOKEN'],
    current_team: ENV['ESA_CURRENT_TEAM'],
  )
end

post '/' do
end
