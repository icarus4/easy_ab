require 'easy_ab/helpers'
require 'easy_ab/experiment'

module EasyAb
  class Error < StandardError; end
  class ExperimentNotFound < Error; end

  class << self
    def config
      @config = nil if Rails.env.development? # Reload in development
      @config ||= YAML.load(ERB.new(File.read("config/easy_ab.yml")).result)
    end

    def configure
      @@configuration ||= Configuration.new
      yield(@@configuration)
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

  class Configuration
    attr_accessor :authorize_admin_with
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

ActiveSupport.on_load(:action_view) do
  include EasyAb::Helpers
end
