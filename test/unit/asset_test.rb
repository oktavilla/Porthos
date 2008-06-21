require File.dirname(__FILE__) + '/../test_helper'
class AssetTest < Test::Unit::TestCase
  fixtures :assets, :taggings, :tags

  def test_should_create
    assert_difference 'Asset.count' do
      asset = create_asset
      assert !asset.new_record?, "#{asset.errors.full_messages.to_sentence}"
      assert File.exists?(asset.path), 'Should store the asset in the filesystem'
    end
  end
  
  def test_should_copy_to_assets_dir
    asset = create_asset(:file => fixture_file_upload('files/fatty.jpg', 'image/jpeg'))
    assert File.exists?(asset.path)
  end
  
  def test_should_destroy
    assert_no_difference 'Asset.count' do
      asset = create_asset
      assert asset.destroy, "Should delete asset"
      assert !File.exists?(asset.path), "Should remove asset from filesystem"
    end
  end

  def test_should_store_file_information
    assert_difference 'Asset.count' do
      asset = create_asset
      assert_not_nil asset.file_name, 'Should create a file_name'
      assert asset.size > 0, 'Should store file size in bytes'
      assert asset.full_name.include?("alien"), 'Should store the original file_name'
      assert_equal 'Alien', asset.title, 'Title should default to humanized original file_name'
      assert_equal 'image/jpeg', asset.mime_type, 'Should extract the mime type'
    end
  end

  def test_should_require_file_on_create
    assert_no_difference 'Asset.count' do
      asset = create_asset(:file => nil)
      assert_not_nil asset.errors.on(:file), "Should require a uploaded file"
    end
  end

  def test_should_handle_assets_with_the_same_file_name
    asset1 = create_asset
    asset2 = create_asset
    assert_not_equal asset1.file_name, asset2.file_name, "Should have different names"
  end

  def test_should_destroy_temp_file_after_create
    asset = create_asset
    assert_equal false, File.exists?(asset.file.local_path), "Should have destroyed the temp file"
  end
  
  def test_should_add_tags
    assert_difference 'Tag.count', 3 do
      asset = create_asset
      asset.tag_names = 'three, four, five'
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
