require 'net/http'

class App < Sinatra::Base
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    Dir[File.join(SOURCES_DIR, '**', '*.rb')].each { |f| also_reload f }
  end

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :esa, ENV['ESA_CLIENT_ID'], ENV['ESA_CLIENT_SECRET'], scope: 'read write'
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
          mrkdwn_in: ['text']
        }
      ],
    }
  end

  def build_auth_link_message(user:, response_url:, text:)
    query = Rack::Utils.build_nested_query({ state: {
      slack: {
        user_id: user.slack_user_id,
        response_url: params[:response_url],
        text: text,
      },
    }})
    msg = {
      attachments: [
        {
          color: 'warning',
          title: 'Please authenticate on your esa.io account :bow:',
          title_link: "#{request.base_url}/auth/esa?#{query}"
        }
      ]
    }
  end

  def build_urge_to_register_team_message()
    {
      response_type: 'in_channel',
      attachments: [
        {
          color: 'warning',
          text: "Please register your esa team `/esasla team <your_esa_team_name>` :bow:",
          mrkdwn_in: ['text'],
        },
      ]
    }
  end

  def handle_command(user:, team:, cmd:, args:)
    case cmd
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

  post '/' do
    msg = {}
    text = params[:text]
    user_id = params[:user_id]
    team_id = params[:team_id]

    team = Team.find(team_id)
    if team.blank?
      team = Team.create!(slack_team_id: team_id)
    end

    user = User.find(user_id)
    if user.blank?
      user = team.users.create!(slack_user_id: user_id)
    end

    if !user.authenticated?
      msg = build_auth_link_message(
        user: user,
        response_url: params[:response_url],
        text: text,
      )
    elsif text&.empty?
      msg = build_usage_message
    else
      m = text.match(/\A(?<cmd>\S+)\s*(?<args>.*)/m)
      team = Team.find(team_id)

      if m[:cmd] != 'team' && !team.registered?
        msg = build_urge_to_register_team_message
      else
        msg = handle_command(
          user: user,
          team: team,
          cmd: m[:cmd],
          args: m[:args]
        )
      end
    end

    json msg
  end

  get '/auth/:name/callback' do
    auth = request.env['omniauth.auth']
    state = request.env['omniauth.params']['state']
    cmd = AuthUserCommand.run(auth: auth, state: state)
    if cmd.success?
      uri = URI.parse(cmd.slack_response_url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req = Net::HTTP::Post.new(uri.request_uri)
      req['Content-Type'] = 'application/json'
      req.body = {
        attachments: [
          {
            color: 'good',
            text: 'Authenticate your account successfully!',
          }
        ]
      }.to_json
      https.start { |x| x.request(req) }
    else
      # TODO: handle errors
    end
    "ok"
  end
end
