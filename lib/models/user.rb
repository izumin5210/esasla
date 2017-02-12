class User
  include Dynamoid::Document

  table name: :users, key: :slack_user_id

  field :esa_access_token
  field :esa_uid
  field :esa_raw_info
end
