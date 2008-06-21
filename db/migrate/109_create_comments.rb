class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer   :commentable_id
      t.string    :commentable_type
      t.string    :name
      t.string    :email
      t.text      :body
      t.timestamps 
    end
    add_index :comments, :commentable_id
  end

  def self.down
    drop_table :comments
  end
end
