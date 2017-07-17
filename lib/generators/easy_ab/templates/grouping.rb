class <%= migration_class_name %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :easy_ab_groupings do |t|
      t.string :participant
      t.string :experiment
      t.string :variant
      t.timestamps
    end

    add_index :easy_ab_groupings, [:experiment, :participant, :variant], unique: true
    add_index :easy_ab_groupings, [:experiment, :created_at]
    add_index :easy_ab_groupings, :participant
  end
end