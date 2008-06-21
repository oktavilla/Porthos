class AddRoleBasedAuthentication < ActiveRecord::Migration
  class Administrator < User
  end
  class SiteAdministrator < Administrator
  end

  def self.up
    
    create_table :roles, :force => true do |t|
      t.string :name
    end
    add_index :roles, :name

    create_table :user_roles, :force => true do |t|
      t.integer  :user_id
      t.integer  :role_id
      t.datetime :created_at
    end
    add_index :user_roles, :user_id
    add_index :user_roles, :role_id

    admin_role = Role.create(:name => 'Admin')
    Administrator.find(:all).each { |u| u.roles << admin_role }
    site_admin_role = Role.create(:name => 'SiteAdmin')
    SiteAdministrator.find(:all).each { |u| u.roles << site_admin_role }

    remove_column :users, :type
  end
  
  def self.down
    drop_table :roles
    drop_table :user_roles
    add_column :users, :type, :string
  end
  
end