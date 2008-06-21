require File.dirname(__FILE__) + '/../test_helper'

class PageTest < Test::Unit::TestCase
  fixtures :pages

  def test_should_create
    assert_difference 'Page.count' do
      page = create_page
      assert !page.new_record?, "#{page.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_require_title
    page = create_page :title => nil
    assert_not_nil page.errors.on(:title), "Should require a title"
  end

private
  def create_page(options={})
    Page.create({
      :title => "About a boy",
      :description => "Pretty crappy movie"
    }.merge(options))
  end
end
