class App < Sinatra::Base
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    Dir[File.join(SOURCES_DIR, '**', '*.rb')].each { |f| also_reload f }
  end

  def esa_client
    @esa_client = Esa::Client.new(
      access_token: ENV['ESA_ACCESS_TOKEN'],
      current_team: ENV['ESA_CURRENT_TEAM'],
    )
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
      attachments: [
        {
          color: 'warning',
          text: text,
        }
      ],
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
        cmd = CreatePostCommand.run(args, esa_client: esa_client)
        if cmd.success?
          msg = {
            response_type: 'in_channel',
            text: 'Created new post',
            attachments: build_attatchments_from_posts([cmd.post]),
          }
        end
      when 'list'
        cmd = FetchPostsCommand.run(args, esa_client: esa_client)
        if cmd.success?
          msg = {
            response_type: 'in_channel',
            attachments: build_attatchments_from_posts(cmd.posts),
          }
        end
      else
        msg = build_usage_message
      end
    end

    json msg
  end
end
