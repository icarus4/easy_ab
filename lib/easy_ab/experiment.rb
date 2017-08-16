module EasyAb
  class Experiment
    attr_reader :name, :variants, :weights, :rules, :winner, :scope

    def initialize(name, options = {})
      @name     = name.to_s
      @variants = options[:variants].map(&:to_s)
      @weights  = options[:weights]
      @rules    = options[:rules]
      @scope    = options[:scope]
      @winner   = options[:winner].nil? ? nil : options[:winner].to_s

      raise ArgumentError, 'Please define variants' if @variants.blank?
      raise ArgumentError, 'Number of variants and weights should be identical' if @weights.present? && @weights.size != @variants.size
      raise ArgumentError, 'Number of variants and rules should be identical' if @rules.present? && @rules.size != @variants.size
      raise ArgumentError, 'All rules should be a Proc' if @rules.present? && @rules.any? { |rule| !rule.is_a?(Proc) }
      raise ArgumentError, 'Scope should be a Proc' if @scope.present? && !@scope.is_a?(Proc)
      raise ArgumentError, 'winner should be one of variants' if @winner && !@variants.include?(@winner)
    end

    def self.find_by_name!(experiment_name)
      experiment_name = experiment_name.to_s
      exp = EasyAb.experiments.all.find { |exp| exp.name == experiment_name }
      raise ExperimentNotFound if exp.nil?
      exp
    end

    # Priority:
    # 1. winner
    # 2. url parameter or assign variant (ex: ab_test(:experiment, variant: 'variant A'))
    # 3. scope
    # 4. rules/weights
    def assign_variant(user_recognition, options = {})
      # 1. winner
      return winner if winner

      grouping = find_grouping_by_user_recognition(user_recognition) || ::EasyAb::Grouping.new(experiment: name, user_id: user_recognition[:user_id], cookie: user_recognition[:cookie])

      # 2. url parameter or assign variant
      if options[:variant] && variants.include?(options[:variant].to_s)
        grouping.variant = options[:variant].to_s
      else
        # 3. scope
        return nil if options[:scope] && !options[:scope].call
        # 4. rules/weights
        grouping.variant ||= flexible_variant(options[:contexted_rules])
        return nil if grouping.variant.nil?
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

    # TODO: add spec
    def find_grouping_by_user_recognition(user_recognition)
      user_id  = user_recognition[:user_id].presence
      cookie   = user_recognition[:cookie].presence
      raise 'User not found: both user_id and cookie are empty' if user_id.nil? && cookie.nil?

      # Cases should take into consideration
      # Case I: user participated experiment with login and return again
      # Case II: user participated experiment with login and return by another device with login
      # Case III: user participated experiment with login and return by the same device, but cookie was cleared between last and this participation
      # => Both II and III already exist a record with the same user_id but different cookie
      #    In the above two cases, we update the cookie of the exising record
      #
      # Case IV: User participated experiment without login and return with login
      # => Assign user_id to the existing record
      #
      # Case V: User participated experiment without login and return without login, too
      grouping = nil
      if user_id # User is signed in
        # Case I, II, III
        return grouping if (grouping = groupings.where(user_id: user_id).first) && ((cookie && grouping.cookie = cookie) || true)
        # Case IV
        return grouping if (cookie && grouping = groupings.where(user_id: nil, cookie: cookie).first) && ((grouping.user_id = user_id) || true) # Assign user_id
      elsif cookie # User is not signed in
        # Case V
        return grouping if grouping = groupings.where(cookie: cookie).first
      end

      grouping
    end

    def groupings
      ::EasyAb::Grouping.where(experiment: name)
    end

    def flexible_variant(contexted_rules = nil)
      if contexted_rules
        variant_by_rule(contexted_rules)
      elsif weights
        weighted_variant
      else
        equal_weighted_variant
      end
    end

    def variant_by_rule(contexted_rules)
      contexted_rules.each_with_index do |rule, i|
        return variants[i] if rule.call
      end

      # If all rules not matched, return nil
      nil
    end

    def weighted_variant
      total = weights.sum
      roll = rand
      sum = 0
      weights.each_with_index do |weight, i|
        sum += weight.to_d / total
        return variants[i] if sum >= roll
      end
      variants.last
    end

    def equal_weighted_variant
      variants.sample
    end
  end
end