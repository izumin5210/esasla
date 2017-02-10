require 'sinatra'
require 'sinatra/reloader' if development?

def esa_client
  @client = Esa::Client.new(
    access_token: ENV['ESA_ACCESS_TOKEN'],
    current_team: ENV['ESA_CURRENT_TEAM'],
  )
end

def default_category
  @default_category = ENV['ESA_DEFAULT_CATEGORY']
end

def create_post(args)
  lines = args.split("\n")
  name, body = lines[0], lines[1..-1].join("\n")
  category = default_category

  p lines
  p name
  p body

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

  # TODO: handle errors

  res.body
end

def fetch_posts(args)
  query = args&.empty? ? "wip:true in:#{default_category}" : args

  res = esa_client.posts(q: query)

  # TODO: handle errors

  res.body['posts']
end

def build_attatchments_from_posts(posts)
  posts.map { |post| build_attatchment_from_post(post) }
end

def build_attatchment_from_post(post)
  { title: post['full_name'],
    title_link: post['url'],
  }
end

def build_usage_message
  text = <<~USAGE
    ```
    Usage:

      /esasla <command> [<args>]

    The commands are:

      create    create new post. the first line is used as a post title.
      list      fetch posts. if you pass args, they will use as search queries.
    ```
  USAGE
  {
    response_type: 'in_channel',
    attachments: [
      {
        color: 'warning',
        text: text,
        mrkdwn: true,
      }
    ],
    mrkdwn: true,
  }
end

post '/' do
  text = params[:text]
  msg = {}

  if text&.empty?
    msg = build_usage_message
  else
    m = text.match(/\A(?<cmd>\S+)\s*(?<args>.*)/m)
    args = m[:args]

    case m[:cmd]
    when 'create'
      post = create_post(args)
      msg = {
        response_type: 'in_channel',
        text: 'Created new post',
        attachments: build_attatchments_from_posts([post]),
      }
    when 'list'
      posts = fetch_posts(args)
      msg = {
        response_type: 'in_channel',
        attachments: build_attatchments_from_posts(posts),
      }
    else
      msg = build_usage_message
    end
  end

  json msg
end
