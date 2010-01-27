class Redirect < ActiveRecord::Base
  validates_presence_of :path, :target
end