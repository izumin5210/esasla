class AuthUserCommand
  include Command

  attr_reader :user,
    :slack_user_id, :slack_response_url,
    :esa_uid, :esa_access_token, :esa_raw_info

  validates :slack_user_id, presence: true
  validates :slack_response_url, presence: true
  validates :esa_uid, presence: true
  validates :esa_access_token, presence: true
  validates :esa_raw_info, presence: true
  validates :user, presence: true

  def initialize(auth:, state:)
    @slack_user_id = state['slack']['user_id']
    @slack_response_url = state['slack']['response_url']
    @esa_uid = auth.uid
    @esa_access_token = auth.credentials.token
    @esa_raw_info = auth.extra.raw_info.to_h
    @user = User.find(slack_user_id)
  end

  def run
    update_user
  end

  private

  def update_user
    user.update_attributes({
      slack_user_id: slack_user_id,
      esa_access_token: esa_access_token,
      esa_uid: esa_uid,
      esa_raw_info: esa_raw_info,
    })
  end
end
