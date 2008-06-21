class AddNotificationEmailToRegistrationForm < ActiveRecord::Migration
  def self.up
    add_column :registration_forms, :notification_person_id, :integer
  end

  def self.down
    remove_column :registration_forms, :notification_person_id
  end
end
