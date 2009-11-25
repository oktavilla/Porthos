class AddStatusToRegistrationsAndRegistrationComments < ActiveRecord::Migration
  def self.up
    add_column :registrations, :status, :integer, :default => 0
    add_column :registrations, :fraud, :boolean, :default => false
    create_table :registration_comments do |t|
      t.references  :registration
      t.text        :body
      t.integer     :status
      t.boolean     :fraud, :default => false
      t.boolean     :updated_registration
      t.references  :user
      t.timestamps 
    end
    
    add_index :registration_comments, :registration_id
    add_index :registration_comments, :user_id
    
    create_table :payments_registration_comments, :id => false do |t|  
      t.references :payment
      t.references :registration_comment
      t.timestamps  
    end
    
    add_index :payments_registration_comments, :payment_id
    add_index :payments_registration_comments, :registration_comment_id
    
    # UPDATE registrations SET status = 1
    #        WHERE
    #         (
    #           type IN ('Order', 'PrivateOrder','CompanyOrder') AND 
    #           (payment_status = 'Completed' OR payment_type = 'invoice') AND
    #           ((dispatch_id IS NOT NULL AND (dispatch_status = 1 OR dispatch_status = 0)) OR (created_at < '2007-12-29 00:00:00' AND shipment_type IS NOT NULL))
    #         ) OR (
    #           type IN ('Donation', 'PrivateDonation', 'CompanyVgDonation', 'PrivateVgDonation', 'VgDonation', 'ParadeDonation') AND 
    #           (payment_status = 'Completed' OR payment_type = 'invoice') 
    #         ) OR (
    #           type NOT IN ('Donation', 'PrivateDonation', 'CompanyVgDonation', 'VgDonation', 'PrivateVgDonation', 'ParadeDonation','Order', 'PrivateOrder','CompanyOrder')
    #         )
    # 
    # UPDATE registrations SET status = 3
    #        WHERE
    #         (
    #           ((payment_type != 'invoice' AND payment_type IS NOT NULL) and (payment_status != 'Completed' OR payment_status IS NULL)) OR
    #           (payment_status = 'Failed' or payment_status = 'Declined')
    #         )
    #
    # UPDATE registrations SET status = 0
    #        WHERE
    #         (
    #           (dispatch_status = 'Unknown error')
    #         )
  end

  def self.down
    remove_table :registration_comments
    remove_table :payments_registration_comments
    remove_column :registrations, :process_status
    remove_column :registrations, :fraud
  end
end
