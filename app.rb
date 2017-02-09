require 'sinatra'
require 'sinatra/reloader' if development?

def esa_client
  @client = Esa::Client.new(
    access_token: ENV['ESA_ACCESS_TOKEN'],
    current_team: ENV['ESA_CURRENT_TEAM'],
  )
end

post '/' do
  lines = params[:text].split("\n")
  name, body = lines[0], lines[1..-1].join("\n")
  category = ENV['ESA_DEFAULT_CATEGORY']

  if name.include?('/')
    m = name.match(/\A(?<category>.*)\/(?<name>(?!\/).*)\Z/)
    name = m[:name]
    category= m[:category]
  end

  res = esa_client.create_post(
    name: name,
    body_md: body,
    category: category,
    user: 'esa_bot',
  )

  msg = {
    response_type: 'in_channel',
    text: 'Created new post',
    attachments: [
      {
        title: res.body['full_name'],
        title_link: res.body['url'],
      }
    ]
  }
  json msg
end
