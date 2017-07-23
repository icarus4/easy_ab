module EasyAb
  class Experiment
    attr_reader :name

    def initialize(name, options = {})
      @name = name
      @options = options
    end

    def self.find_by_name(experiment_name)
      exp = EasyAb.experiments.all.find { |exp| exp.name == experiment_name }
      raise ExperimentNotFound if exp.nil?
      exp
    end
  end
end