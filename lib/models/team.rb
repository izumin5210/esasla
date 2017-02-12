class Team
  include Dynamoid::Document

  table name: :teams, key: :slack_team_id

  field :esa_team_name
  field :esa_default_category
end
