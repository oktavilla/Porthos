require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :taggings, :tags, :assets

  def test_should_add_tags
    assert_difference 'Tag.count', 3 do
      asset = create_asset
      asset.tags = 'three, four, five'
      assert_equal 'three, four, five', asset.tag_names, 'Should have created tags for asset'
    end
  end
  
  def test_should_find_tagged_with
    assets = Asset.find_tagged_with(:tags => 'test')
    assert_equal 2, assets.size, "Should have found 2 assets"
  end
  
protected

  def create_asset(options = {})
    Asset.create({
        :file => fixture_file_upload('files/alien.jpg', 'image/jpeg')
    }.merge(options))
  end
end
