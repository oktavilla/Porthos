class AddRegistrationFormIdToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :registration_form_id, :integer
    add_index  :registrations, :registration_form_id
  end

  def self.down
    remove_column :registrations, :registration_form_id
  end
end
