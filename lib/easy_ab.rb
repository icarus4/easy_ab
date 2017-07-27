require 'easy_ab/experiment'
require 'easy_ab/engine' if defined?(Rails)
require 'easy_ab/helpers'
require 'easy_ab/version'

module EasyAb
  class Error < StandardError; end
  class ExperimentNotFound < Error; end

  class << self
    def config
      # @config = nil if Rails.env.development? # Reload in development
      # @config ||= YAML.load(ERB.new(File.read("config/easy_ab.yml")).result)
      @@config
    end

    def configure
      @@config ||= Config.new
      yield(@@config)
    end

    def experiments
      @@experiments ||= Experiments.new

      if block_given?
        yield(@@experiments)
      else
        @@experiments
      end
    end
  end

  class Config
    attr_accessor :authorize_admin_with, :user_signed_in_method
  end

  class Experiments
    def initialize
      @experiments = []
    end

    def define(name, options = {})
      @experiments << ::EasyAb::Experiment.new(name, options)
    end

    def all
      @experiments
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include ::EasyAb::Helpers
end

ActiveSupport.on_load(:action_view) do
  include ::EasyAb::Helpers
end
