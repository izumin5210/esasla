json.response_type 'in_channel'
json.text 'Created new post'

attachments = @posts.map do |post|
  {
    title: post['full_name'],
    title_link: post['url'],
  }
end

json.attachments attachments do |attachment|
  json.extract! attachment, :title, :title_link
  json.fallback attachment[:title]
end
