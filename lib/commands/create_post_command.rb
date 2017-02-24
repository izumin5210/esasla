class CreatePostCommand
  include Command

  attr_reader :team, :user, :name, :body, :category, :post

  validates :team, presence: true
  validates :user, presence: true
  validates :name, presence: true
  validates :category, presence: true

  def initialize(args, team:, user:)
    @team = team
    @user = user
    perse_args(args)
  end

  def run
    res = esa_client.create_post(
      name: name,
      body_md: body,
      category: category,
    )

    # TODO: handle errors

    @post = res.body
  end

  private

  def perse_args(args)
    lines = args.split("\n")
    @name, @body = lines[0], lines[1..-1].join("\n")
    @category = team.esa_default_category

    if name.include?('/')
      m = name.match(/\A(?<category>.*)\/(?<name>(?!\/).*)\Z/)
      @name = m[:name]
      @category= m[:category]
    end
  end

  def esa_client
    @esa_client ||= Esa::Client.new(
      access_token: user.esa_access_token,
      current_team: team.esa_team_name,
    )
  end
end
