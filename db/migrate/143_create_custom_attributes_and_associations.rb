class CreateCustomAttributesAndAssociations < ActiveRecord::Migration

  def self.up
    create_table :custom_attributes do |t|
      t.string    :type
      t.integer   :context_id
      t.string    :context_type
      t.integer   :field_id
      t.string    :handle
      t.string    :string_value
      t.text      :text_value
      t.datetime  :date_time_value
      t.timestamps
    end
    
    add_index :custom_attributes, [:context_id, :context_type]
    add_index :custom_attributes, :field_id
    add_index :custom_attributes, :handle
    
    create_table :custom_associations do |t|
      t.integer :context_id
      t.string  :context_type
      t.integer :target_id
      t.string  :target_type
      t.string  :relationship
      t.integer :field_id
      t.string  :handle
      t.integer :position
      t.timestamps
    end

    add_index :custom_associations, [:context_id, :context_type]
    add_index :custom_associations, [:target_id, :target_type]
    add_index :custom_associations, :field_id
    add_index :custom_associations, :handle
  end
  
  def self.down
    drop_table :custom_attributes
    drop_table :custom_associations
  end

end