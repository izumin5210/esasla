class SetDefaultCategoryCommand
  include Command
  
  attr_reader :team, :default_category

  validates :team, presence: true

  def initialize(team:, default_category:)
    @team = team
    @default_category = default_category
  end

  def run
    team.update_attributes(esa_default_category: default_category)
  end
end
