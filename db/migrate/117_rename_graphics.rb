class RenameGraphics < ActiveRecord::Migration
  def self.up
    rename_table :graphics, :porthos_graphics
  end

  def self.down
    rename_table :porthos_graphics, :graphics
  end
end