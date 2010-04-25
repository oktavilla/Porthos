class MoveFieldSetAssocitationToPages < ActiveRecord::Migration

  def self.up
    add_column :pages, :field_set_id, :integer
    add_index  :pages, :field_set_id

    PageLayout.find(:all, :conditions => 'field_set_id IS NOT NULL').each do |page_layout|
      Page.update_all("field_set_id = #{page_layout.field_set_id}", ['page_layout_id = ?', page_layout.id])
    end

    remove_column :page_layouts, :field_set_id
  end

  def self.down
    add_column :page_layouts, :field_set_id
    add_index :page_layouts,  :field_set_id
  end

end