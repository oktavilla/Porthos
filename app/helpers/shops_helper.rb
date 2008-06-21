module ShopsHelper

  def product_collection(title, options = {}, &block)
    block_to_partial 'products/collection', options.merge(:title => title), &block
  end

end
