class FetchPostsCommand
  include Command

  attr_reader :esa_client, :query, :posts

  validates :esa_client, presence: true
  validates :query, presence: true

  def initialize(args, esa_client:)
    @esa_client = esa_client
    @query = args&.empty? ? default_query : args
  end

  def run
    res = esa_client.posts(q: query)

    # TODO: handle errors

    @posts = res.body['posts']
  end

  private

  def default_query
    "wip:true in:#{default_category}"
  end

  def default_category
    ENV['ESA_DEFAULT_CATEGORY']
  end
end
