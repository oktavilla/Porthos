class AddSessionIdToRegistration < ActiveRecord::Migration
  def self.up
    add_column :registrations, :session_id, :string
  end

  def self.down
    remove_column :registrations, :session_id
  end
end
