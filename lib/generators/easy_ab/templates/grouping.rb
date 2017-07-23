class <%= migration_class_name %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :easy_ab_groupings do |t|
      t.string :participant
      t.string :experiment
      t.string :variant
      t.timestamps
    end

    add_index :easy_ab_groupings, [:experiment, :participant, :variant], unique: true, name: 'uniq_index_of_easy_ab_groupings'
    add_index :easy_ab_groupings, :participant
  end
end