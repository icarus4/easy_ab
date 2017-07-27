module EasyAb
  module Helpers
    # Return variant of specified experiment for current user
    def ab_test(experiment_name, options = {})
      experiment_name = experiment_name.to_s
      user_recognition = find_ab_test_user_recognition(options)

      if respond_to?(:request) && params[:ab_test] && params[:ab_test][experiment_name]
        # Check current user is admin or not by proc defined by gem user
        if current_user_is_admin?
          options[:variant] ||= params[:ab_test][experiment_name]
        end
        # TODO: exclude bot
      end

      experiment = EasyAb::Experiment.find_by_name!(experiment_name)

      @variant_cache ||= {}
      @variant_cache[experiment_name] ||= experiment.assign_variant(user_recognition, options)
    end

    private

      def find_ab_test_user_recognition(options = {})
        user_recognition = {}

        # TODO:
        # return (raise NotImplementedError) if options[:user] && (users << options[:user])

        user_recognition[:id] = current_user.id if respond_to?(:current_user, true) && current_user_signed_in?
        # Controllers and views
        user_recognition[:cookie] = find_or_create_easy_ab_cookie if respond_to?(:request)

        user_recognition
      end

      def current_user_signed_in?
        user_signed_in_method_proc.call
      end

      def current_user_is_admin?
        authorize_admin_with_proc.call
      end

      def authorize_admin_with_proc
        Proc.new { instance_exec &EasyAb.config.authorize_admin_with }
      end

      def user_signed_in_method_proc
        Proc.new { instance_exec &EasyAb.config.user_signed_in_method }
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