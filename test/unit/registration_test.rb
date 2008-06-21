require File.dirname(__FILE__) + '/../test_helper'

class RegistrationTest < Test::Unit::TestCase
  fixtures :registrations

  def test_should_check_field_lengths
    registration = registrations(:pencil_shopping)
  #  registration.update_attributes(:first_name => 'John', :last_name => 'Doe', :address => 'Really loooooooooooooooooooooooooooooooooooong address')
   # 
  #  raise registration.errors.on(:address).inspect
      #assert registration.errors.on(:address), "Should require a message if closed"
  end
end
