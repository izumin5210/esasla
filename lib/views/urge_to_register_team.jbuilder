json.response_type 'in_channel'

attachments = [
  {
    color: 'warning',
    text: "Please register your esa team `/esasla team <your_esa_team_name>` :bow:",
    mrkdwn_in: ['text'],
  },
]

json.attachments attachments do |attachment|
  json.extract! attachment, :color, :text, :mrkdwn_in
end
