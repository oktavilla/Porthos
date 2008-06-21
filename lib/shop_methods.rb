module ShopMethods

  def find_cart
    @shop = Shop.find_by_slug(params[:shop_id]) or raise ActiveRecord::RecordNotFound
    redirect_to(closed_shop_path(@shop)) and return if @shop.closed?
    
    discount_key = Discount.session_key(@shop)
  
    if params[:coupon]
      if discount = Discount.active.find_by_code(params[:coupon].upcase)
        session[discount_key] = discount.id if discount.shop_id == @shop.id
      else
        flash[:discount_notice] = "Kampanjkoden ”#{params[:coupon]}” kunde inte hittas, kontrollera att du skrivit rätt kod och att erbjudandet inte har gått ut."
      end
    end

    if cart_id = session[Cart.session_key(@shop)]
      @cart = Cart.find(cart_id)
      @cart.update_attributes(:discount_id => session[discount_key]) if session[discount_key] and @cart.discount_id.nil?
      @discount = @cart.discount
    end
    @cart
  end

  def find_or_create_cart
    unless find_cart
      @cart = Cart.create(:shop => @shop, :discount_id => session[Discount.session_key(@shop)])
      session[@cart.session_key] = @cart.id
      @discount = @cart.discount
    end
  end

end