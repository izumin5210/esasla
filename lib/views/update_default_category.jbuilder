json.response_type 'in_channel'

attachments = [
  {
    color: 'good',
    text: "Update default category to `#{@team.esa_default_category}` successfully!",
    mrkdwn_in: ['text']
  },
]

json.attachments attachments do |attachment|
  json.extract! attachment, :color, :text, :mrkdwn_in
  json.fallback attachment[:text]
end
