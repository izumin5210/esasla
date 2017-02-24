require 'net/http'

class App < Sinatra::Base
  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
    Dir[File.join(SOURCES_DIR, '**', '*.rb')].each { |f| also_reload f }
  end

  set :root, ROOT_DIR
  set :views, [File.join(SOURCES_DIR, 'views')]

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :esa, ENV['ESA_CLIENT_ID'], ENV['ESA_CLIENT_SECRET'], scope: 'read write'
  end

  def handle_command(user:, team:, cmd:, args:)
    case cmd
    when 'create'
      cmd = CreatePostCommand.run(args, team: team, user: user)
      if cmd.success?
        @text = 'Created new post successfully!'
        @posts = [cmd.post]
        jbuilder :posts
      end
    when 'list'
      cmd = FetchPostsCommand.run(args, team: team, user: user)
      if cmd.success?
        @text = 'Retrieved posts successfully!'
        @posts = cmd.posts
        jbuilder :posts
      end
    when 'team'
      cmd = BindSlackAndEsaTeamCommand.run(
        user: user,
        team: team,
        esa_team_name: args,
      )
      if cmd.success?
        if cmd.updated?
          @team = cmd.team
          jbuilder :register_team
        elsif cmd.team.registered?
          @team = cmd.team
          jbuilder :current_team
        else
          jbuilder :urge_to_register_team
        end
      end
    when 'category'
      cmd = SetDefaultCategoryCommand.run(team: team, default_category: args)
      if cmd.success?
        @team = cmd.team
        jbuilder :update_default_category
      end
    else
      jbuilder :usage
    end
  end

  post '/callback' do
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
      @user = user
      @text = text
      @response_url = params[:response_url]
      @auth_url = "#{request.base_url}/auth/esa"
      jbuilder :require_authentication
    elsif text&.empty?
      jbuilder :usage
    else
      m = text.match(/\A(?<cmd>\S+)\s*(?<args>.*)/m)
      team = Team.find(team_id)

      if m[:cmd] != 'team' && !team.registered?
        # TODO
        jbuilder :urge_to_register_team
      else
        handle_command(
          user: user,
          team: team,
          cmd: m[:cmd],
          args: m[:args]
        )
      end
    end
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
