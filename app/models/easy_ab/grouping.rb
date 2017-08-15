module EasyAb
  class Grouping < ActiveRecord::Base
    self.table_name = 'easy_ab_groupings'

    validates :experiment, presence: true
    validates :variant, presence: true
    validates :user_id, uniqueness: { scope: [:experiment] }
    validate :cookie_should_be_unique_when_user_id_is_nil
    validate :user_should_be_present

    private

      def user_should_be_present
        if cookie.nil? && user_id.nil?
          errors.add(:user_id, "or cookie can't be blank")
          errors.add(:cookie, "or user_id can't be blank")
        end
      end

      def cookie_should_be_unique_when_user_id_is_nil
        if user_id.nil?
          errors.add(:cookie, "already exists") if self.class.where(cookie: cookie, user_id: nil).exists?
        end
      end
  end
end