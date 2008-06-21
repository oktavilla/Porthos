class CreateRegistrationForms < ActiveRecord::Migration
  def self.up
    create_table :registration_forms do |t|
      t.integer :contact_person_id
      t.string  :name
      t.string  :template
      t.boolean :send_email_response
      t.boolean :replyable_email
      t.string  :reply_to_email
      t.string  :email_subject
      t.text    :email_body
      t.timestamps 
    end
  end

  def self.down
    drop_table :registration_forms
  end
end
