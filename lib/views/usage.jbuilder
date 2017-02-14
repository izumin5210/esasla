text = <<~USAGE
  ```
  Usage:

    /esasla <command> [<args>]

  The commands are:

    create    create new post. the first line is used as a post title.
    list      fetch posts. if you pass args, they will use as search queries.
    team      register or show your esa.io team.
    category  register default category for creating/fetching esa posts
  ```
USAGE

attachments = [
  {
    color: 'warning',
    text: text,
    mrkdwn_in: ['text'],
  },
]

json.attachments attachments do |attachment|
  json.extract! attachment, :color, :text, :mrkdwn_in
end
