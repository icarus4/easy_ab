module EasyAb
  class Grouping < ActiveRecord::Base
    self.table_name = 'easy_ab_groupings'

    validates :experiment, presence: true
    validates :variant, presence: true
    validates :user_id,     uniqueness: { scope: [:experiment] }
    validates :cookie, uniqueness: { scope: [:experiment] }
    validate :user_should_be_present

    private

      def user_should_be_present
        if cookie.nil? && user_id.nil?
          errors.add(:user_id, "or cookie can't be blank")
          errors.add(:cookie, "or user_id can't be blank")
        end
      end
  end
end