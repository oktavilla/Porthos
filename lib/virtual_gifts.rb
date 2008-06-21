module VirtualGifts

  def self.included(controller)
    controller.send :before_filter, :current_vg_cart
    controller.send :helper_method, :current_vg_cart
  end

protected
  
  def current_vg_cart
    @vg_cart ||= find_or_create_cart
  end
  
  def find_or_create_cart
    session[:vg_cart_id] ? VgCart.find(session[:vg_cart_id]) : create_cart
  rescue ActiveRecord::RecordNotFound
    create_cart
  end
  
  def create_cart
    returning(VgCart.create) do |cart|
      session[:vg_cart_id] = cart.id
    end
  end
  
end