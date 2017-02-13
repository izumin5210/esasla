class Team
  include Dynamoid::Document

  table name: :teams, key: :slack_team_id

  field :esa_team_name
  field :esa_default_category

  has_many :users

  def registered?
    esa_team_name.present?
  end
end
