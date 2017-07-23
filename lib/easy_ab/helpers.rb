module EasyAb
  module Helpers
    # Return variant of specified experiment for current user
    def ab_test(experiment_name, options = {})
      participants = find_ab_test_participants(options)

      if params[:ab_test] && params[:ab_test][experiment_name]
        # TODO: only admin can use url parameter to switch variant
        options[:variant] ||= params[:ab_test][experiment_name]
        # TODO: exclude bot
      end

      experiment = EasyAb::Experiment.find_by_name(experiment_name)
    end

    private

      def find_ab_test_participants(options = {})
        participants = []

        return (raise NotImplementedError) if options[:participant] && (participants << options[:participant])

        # Controllers and views
        if respond_to?(:request)
          participants << find_or_create_easy_ab_cookie
        end

        # EasyAb::Participant.normalize(participants)
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