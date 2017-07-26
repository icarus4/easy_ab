module EasyAb
  class Grouping < ActiveRecord::Base
    self.table = 'easy_ab_groupings'

    validates :experiment, presence: true
    validates :variant, presence: true
    validates :user_id,     uniqueness: { scope: [:experiment] }
    validates :user_cookie, uniqueness: { scope: [:experiment] }
    validate :user_should_be_present

    private

      def user_should_be_present
        if user_cookie.nil? && user_id.nil?
          errors.add(:user_id, "or user_cookie can't be blank")
          errors.add(:user_cookie, "or user_id can't be blank")
        end
      end
  end
end