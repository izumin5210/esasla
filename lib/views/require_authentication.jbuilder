query = Rack::Utils.build_nested_query({ state: {
  slack: {
    user_id: @user.slack_user_id,
    response_url: @response_url,
    text: @text,
  },
}})

attachments = [
  {
    color: 'warning',
    title: 'Please authenticate on your esa.io account :bow:',
    title_link: "#{@auth_url}?#{query}"
  }
]

json.attachments attachments do |attachment|
  json.extract! attachment, :color, :title, :title_link
  json.fallback attachment[:title]
end
