class CreatePostCommand
  include Command

  attr_reader :esa_client, :name, :body, :category, :post

  validates :esa_client, presence: true
  validates :name, presence: true
  validates :category, presence: true

  def initialize(args, esa_client:)
    @esa_client = esa_client
    perse_args(args)
  end

  def run
    res = esa_client.create_post(
      name: name,
      body_md: body,
      category: category,
      user: 'esa_bot',
    )

    # TODO: handle errors

    @post = res.body
  end

  private

  def perse_args(args)
    lines = args.split("\n")
    @name, @body = lines[0], lines[1..-1].join("\n")
    @category = default_category

    if name.include?('/')
      m = name.match(/\A(?<category>.*)\/(?<name>(?!\/).*)\Z/)
      @name = m[:name]
      @category= m[:category]
    end
  end

  def default_category
    ENV['ESA_DEFAULT_CATEGORY']
  end
end
