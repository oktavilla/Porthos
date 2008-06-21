class AddStiToRegistrationForms < ActiveRecord::Migration
  def self.up
    add_column :registration_forms, :type, :string
    add_column :registration_forms, :target_code, :string
    add_column :registration_forms, :default_amounts, :string
  end

  def self.down
    remove_column :registration_forms, :type
    remove_column :registration_forms, :target_code
    remove_column :registration_forms, :default_amounts
  end
end
