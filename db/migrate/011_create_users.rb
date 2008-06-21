class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.boolean   :admin,              :default => false
      t.string    :first_name
      t.string    :last_name
      t.string    :login
      t.string    :email
      t.string    :phone
      t.string    :cellphone
      t.string    :crypted_password,   :limit => 40
      t.string    :salt,               :limit => 40
      t.datetime  :created_at
      t.datetime  :updated_at
      t.string    :remember_token
      t.datetime  :remember_token_expires_at
    end
    User.create(
      :first_name => 'Winston',
      :last_name  => 'Design',
      :login      => 'admin',
      :email      => 'email@example.com',
      :password   => 'password',
      :password_confirmation => 'password'
    )
  end

  def self.down
    drop_table :users
  end
end
