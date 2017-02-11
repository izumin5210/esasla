module Command
  extend ActiveSupport::Concern
  include ActiveModel::Model

  module ClassMethods
    def run(*args)
      new(*args).tap do |command|
        command.run if command.valid?
      end
    end
  end

  def run
    raise NotImplementedError
  end

  def success?
    errors.none?
  end
end
