json.response_type 'in_channel'

attachments = [
  {
    color: 'good',
    text: "current team: #{@team.esa_team_name}.esa.io",
  },
]

json.attachments attachments do |attachment|
  json.extract! attachment, :color, :text, :mrkdwn_in
  json.fallback attachment[:text]
end
