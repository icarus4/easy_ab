module EasyAb
  class Experiment
    attr_reader :name, :variants

    def initialize(name, options = {})
      @name = name.to_s
      @variants = options[:variants]
      @options = options

      raise ArgumentError, "Please define variants" if @variants.blank?
    end

    def self.find_by_name!(experiment_name)
      experiment_name = experiment_name.to_s
      exp = EasyAb.experiments.all.find { |exp| exp.name == experiment_name }
      raise ExperimentNotFound if exp.nil?
      exp
    end

    def assign_variant(user_recognition, options = {})
      grouping = find_grouping_by_user_recognition(user_recognition) || ::EasyAb::Grouping.new(experiment: name, user_id: user_recognition[:id], cookie: user_recognition[:cookie])

      if options[:variant] && variants.include?(options[:variant])
        grouping.variant = options[:variant]
      else
        # TODO: implement flexible assignment
        grouping.variant ||= flexibly_assign_variant
      end

      if grouping.changed?
        begin
          grouping.save!
        rescue ActiveRecord::RecordNotUnique
          grouping = find_grouping_by_user_recognition(user_recognition)
        rescue ActiveRecord::RecordInvalid => e
          if grouping.errors[:user_id].present? || grouping.errors[:cookie].present?
            grouping = find_grouping_by_user_recognition(user_recognition)
          else
            raise e
          end
        end
      end

      grouping.variant
    end

    def find_grouping_by_user_recognition(user_recognition)
      user_id = user_recognition[:id]
      cookie  = user_recognition[:cookie]
      grouping = nil

      raise 'should assign a cookie' unless cookie

      # If user login
      if user_id
        # User participated experiment with login and this time
        return grouping if grouping = self.groupings.where(user_id: user_id, cookie: cookie).first
        # User participated experiment without login, but this time with login => assign user_id to existing record
        return grouping if (grouping = self.groupings.where(user_id: nil, cookie: cookie).first) && grouping.user_id = user_id
      else # If user not login
        return grouping if grouping = self.groupings.where(cookie: cookie).first
      end

      # User have yet to participate experiment
      nil
    end

    def groupings
      ::EasyAb::Grouping.where(experiment: name)
    end

    def flexibly_assign_variant
      # TODO: implement flexible assignment
      variants.sample
    end
  end
end