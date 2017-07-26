class <%= migration_class_name %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :easy_ab_groupings do |t|
      t.integer :user_id
      t.string :user_cookie
      t.string :experiment
      t.string :variant
      t.timestamps
    end

    add_index :easy_ab_groupings, [:experiment, :user_id], unique: true
    add_index :easy_ab_groupings, :user_id
    add_index :easy_ab_groupings, :user_cookie
  end
end