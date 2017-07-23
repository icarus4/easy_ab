require 'easy_ab/helpers'

module EasyAb
  class Error < StandardError; end
  class ExperimentNotFound < Error; end

  def self.config
    @config = nil if Rails.env.development? # Reload in development
    @config ||= YAML.load(File.read("config/easy_ab.yml"))
  end
end

ActiveSupport.on_load(:action_view) do
  include EasyAb::Helpers
end
