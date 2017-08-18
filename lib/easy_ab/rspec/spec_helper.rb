module EasyAb
  module RSpec
    module SpecHelper
      def assign_variant(user, experiment, variant)
        g = EasyAb::Grouping.find_or_initialize_by(user_id: user.id, experiment: experiment)
        g.variant = variant
        g.save!
      end
    end
  end
end