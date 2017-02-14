json.response_type 'in_channel'

attachments = [
  {
    color: 'good',
    text: "Register #{@team.esa_team_name}.esa.io successfully!",
  },
]

json.attachments attachments do |attachment|
  json.extract! attachment, :color, :text
end
