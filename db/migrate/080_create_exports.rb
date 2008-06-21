class CreateExports < ActiveRecord::Migration
  def self.up
    create_table :exports do |t|
      t.string :registration_type
      t.datetime :from
      t.datetime :through
      t.timestamps
    end
  end

  def self.down
    drop_table :exports
  end
end
