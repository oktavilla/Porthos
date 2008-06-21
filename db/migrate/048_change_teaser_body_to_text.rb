class ChangeTeaserBodyToText < ActiveRecord::Migration
  def self.up
    change_column :teasers, :body, :text
  end

  def self.down
    change_column :teasers, :body, :string
  end
end
