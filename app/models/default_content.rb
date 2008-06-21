# == Schema Information
# Schema version: 76
#
# Table name: default_contents
#
#  id              :integer(11)   not null, primary key
#  position        :integer(11)   
#  column_position :integer(11)   
#  page_layout_id  :integer(11)   
#  resource_type   :string(255)   
#  resource_id     :integer(11)   
#  created_at      :datetime      
#  updated_at      :datetime      
#

class DefaultContent < ActiveRecord::Base
  belongs_to :page_layout
  belongs_to :resource, :polymorphic => true
end
