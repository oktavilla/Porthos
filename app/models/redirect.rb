class Redirect < ActiveRecord::Base
  validates_presence_of :path, :target
  validates_length_of :path, :minimum => 2
end