module EasyAb
  class Experiment
    attr_reader :name, :variants, :weights

    def initialize(name, options = {})
      @name = name.to_s
      @variants = options[:variants]
      @weights = options[:weights]

      raise ArgumentError, 'Please define variants' if @variants.blank?
      raise ArgumentError, 'Number of variants and weights should be identical' if @weights.present? && @weights.size != @variants.size
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
        grouping.variant ||= flexible_variant
      end

      if grouping.changed? && !options[:skip_save]
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

      if user_id # If user login
        # Case I: User participated experiment with login and return again
        # Case II: user participated experiment with login and return by another device with login
        # Case III: user participated experiment with login and return by the same device, but cookie was cleared between last and this participation
        # => Both II and III already exist a record with the same user_id but different cookie
        # In the above two cases, we update the cookie of the exising record
        return grouping if (grouping = groupings.where(user_id: user_id).first) && ((cookie && grouping.cookie = cookie) || true)

        # User participated experiment without login, but this time with login => assign user_id to the existing record
        return grouping if (grouping = groupings.where(user_id: nil, cookie: cookie).first) && grouping.user_id = user_id
      else # If user not login
        return grouping if grouping = groupings.where(cookie: cookie).first
      end

      # User have yet to participate experiment
      nil
    end

    def groupings
      ::EasyAb::Grouping.where(experiment: name)
    end

    def flexible_variant
      if weights
        weighted_variant
      else
        equal_weighted_variant
      end
    end

    def weighted_variant
      total = weights.sum
      roll = rand
      sum = 0
      weights.each_with_index do |weight, index|
        sum += weight.to_d / total
        return variants[index] if sum >= roll
      end
      variants.last
    end

    def equal_weighted_variant
      variants.sample
    end
  end
end