class FetchPostsCommand
  include Command

  attr_reader :team, :user, :query, :posts

  validates :team, presence: true
  validates :user, presence: true
  validates :query, presence: true

  def initialize(args, team:, user:)
    @team = team
    @user = user
    @query = args&.empty? ? default_query : args
  end

  def run
    res = esa_client.posts(q: query)

    # TODO: handle errors

    @posts = res.body['posts']
  end

  private

  def default_query
    "wip:true in:#{team.esa_default_category}"
  end

  def esa_client
    @esa_client ||= Esa::Client.new(
      access_token: user.esa_access_token,
      current_team: team.esa_team_name,
    )
  end
end
