module EasyAb
  class Grouping < ActiveRecord::Base
    self.table = 'easy_ab_groupings'

    validates :experiment, presence: true
    validates :participant, presence: true
    validates :variant, presence: true
  end
end