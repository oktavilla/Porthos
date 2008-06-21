class CreateActivityGroups < ActiveRecord::Migration
  def self.up
    create_table :activity_groups, :force => true do |t|
      t.string :name
      t.timestamps 
    end
    add_column :registrations, :activity_group_id, :integer
  end

  def self.down
    drop_table :activity_groups
    remove_column :registrations, :activity_group_id
  end
end
