class AddNumberOfPersonsToRegistrations < ActiveRecord::Migration
  def self.up
    add_column :registrations, :school, :string
    add_column :registrations, :school_class, :string
    add_column :registrations, :number_of_persons, :integer
  end

  def self.down
    remove_column :registrations, :school
    remove_column :registrations, :school_class
    remove_column :registrations, :number_of_persons
  end
end
