class BindSlackAndEsaTeamCommand
  include Command
  
  attr_reader :team, :user, :esa_team_name, :updated

  validates :user, presence: true
  validates :team, presence: true

  def initialize(user:, team:, esa_team_name:)
    @user = user
    @team = team
    @esa_team_name = esa_team_name
    @updated = false
  end

  def run
    if esa_team_name.present?
      if esa_team_exists?
        update_team
      else
        # TODO: handle errors
      end
    end
  end

  def updated?
    updated
  end

  private

  def update_team
    team.update_attributes(esa_team_name: esa_team_name)
    @updated = true
  end

  def esa_team_exists?
    esa_teams = fetch_esa_teams
    esa_teams.one? { |t| t['name'] == esa_team_name }
  end

  def fetch_esa_teams
    res = esa_client.teams
    # TODO: handle errors
    res.body['teams']
  end

  def esa_client
    Esa::Client.new(access_token: user.esa_access_token)
  end
end
