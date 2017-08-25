module EasyAb
  module Helpers
    # Return variant of specified experiment for current user
    def ab_test(experiment_name, options = {})
      experiment_name = experiment_name.to_s
      user_recognition = find_ab_test_user_recognition(options)

      if respond_to?(:request) && params[:ab_test] && params[:ab_test][experiment_name]
        # Check current user is admin or not by proc defined by gem user
        if Rails.env.development? || easy_ab_user_is_admin?(options)
          options[:variant] ||= params[:ab_test][experiment_name]
        end
        # TODO: exclude bot
      end

      experiment = EasyAb::Experiment.find_by_name!(experiment_name)

      # Obtain context for rules
      if experiment.rules.present?
        @rules_with_current_context ||= experiment.rules.map { |rule| Proc.new { instance_exec(&rule)} }
        options[:contexted_rules] = @rules_with_current_context
      end

      # Obtain context for scope
      if experiment.scope.present?
        @scope ||= Proc.new { instance_exec(&experiment.scope) }
        options[:scope] = @scope
      end

      @variant_cache                                            ||= {}
      @variant_cache[easy_ab_user_id(options)]                  ||= {}
      @variant_cache[easy_ab_user_id(options)][experiment_name] ||= experiment.assign_variant(user_recognition, options)
      variant = @variant_cache[easy_ab_user_id(options)][experiment_name]
      block_given? ? yield(variant) : variant
    end

    # Return variant of the specified user/experiment.
    # Return nil if the user has not joined the experiment.
    def find_easy_ab_variant(user, experiment)
      grouping = ::EasyAb::Grouping.find_by(user_id: user.id, experiment: experiment)
      grouping ? grouping.variant : nil
    end

    # Return all participated experiments and the corresponding variants for current user
    # Return format:
    # {
    #   'experiment 1' => 'variant 1',
    #   'experiment 2' => 'variant 2',
    #   ...
    # }
    def all_participated_experiments(options = {})
      user_recognition = find_ab_test_user_recognition(options)
      groupings = if user_recognition[:user_id]
                    EasyAb::Grouping.where(user_id: user_recognition[:user_id])
                  else
                    EasyAb::Grouping.where(cookie: user_recognition[:cookie])
                  end

      experiments = {}
      groupings.each do |grouping|
        experiments[grouping.experiment] = grouping.variant
      end
      experiments
    end

    # Internal use for statementdog.com
    # Only supports weighting-based experiments without scope.
    # Never use this API with rule-based experiments or any experiments with scope.
    def ab_test_user(experiment_name, user:, **options)
      experiment_name = experiment_name.to_s
      user_recognition = { user_id: user.id }

      experiment = EasyAb::Experiment.find_by_name!(experiment_name)
      @ab_test_user_cache ||= {}
      @ab_test_user_cache[experiment_name] ||= experiment.assign_variant(user_recognition, options)
      variant = @ab_test_user_cache[experiment_name]
      block_given? ? yield(variant) : variant
    end

    def assign_variant!(user, experiment, variant)
      g = EasyAb::Grouping.find_or_initialize_by(user_id: user.id, experiment: experiment)
      g.variant = variant
      g.save!
      g
    end

    private

      def find_ab_test_user_recognition(options = {})
        user_recognition = {}

        # TODO:
        # return (raise NotImplementedError) if options[:user] && (users << options[:user])

        user_recognition[:user_id] = easy_ab_user_id(options)

        # Controllers and views
        user_recognition[:cookie] = find_or_create_easy_ab_cookie if respond_to?(:request)

        user_recognition
      end

      def easy_ab_user_signed_in?
        current_user_signed_in?
      end

      def current_user_signed_in?
        user_signed_in_method_proc.call
      end

      def easy_ab_user_id(options)
        if options[:user]
          options[:user].id
        elsif easy_ab_user_signed_in?
          current_user_id
        else
          nil
        end
      end

      def current_user_id
        current_user_id_proc.call
      end

      def easy_ab_user_is_admin?(options)
        options[:user] ? false : current_user_is_admin?
      end

      def current_user_is_admin?
        authorize_admin_with_proc.call
      end

      def authorize_admin_with_proc
        @authorize_admin_with_proc ||= Proc.new { instance_exec &EasyAb.config.authorize_admin_with }
      end

      def current_user_id_proc
        @current_user_id_proc ||= Proc.new { instance_exec &EasyAb.config.current_user_id }
      end

      def user_signed_in_method_proc
        @user_signed_in_method_proc ||= Proc.new { instance_exec &EasyAb.config.user_signed_in_method }
      end

      def find_or_create_easy_ab_cookie
        cookie_key = :easy_ab
        value = cookies[cookie_key]
        value = if value
                  value.gsub(/[^a-z0-9\-]/i, "")
                else
                  SecureRandom.uuid
                end
        cookies[cookie_key] = { value: value, expires: 30.days.from_now }

        value
      end
  end
end