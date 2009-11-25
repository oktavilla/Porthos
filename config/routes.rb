ActionController::Routing::Routes.draw do |map|
  # Sample resource route with options:
  # map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  # map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.

  map.resources :registrations
  map.connect '/payments/update', :controller => 'payments', :action => 'update'
  map.resources :payments, :member => { :pending => :get }

  map.with_options :controller => 'assets', :action => 'show' do |asset|
    asset.display_image  '/images/:size/:id.:format'
    asset.display_movie  '/movies/:id.:format'
    asset.download_asset '/assets/:id.:format'
  end

  shop_prefix = '/butik/:shop_id'

  map.resources :pages, :member => { :comment => :post }
  map.resources :page_collections
  
  map.login  '/login',  :controller => 'user/sessions', :action => 'new'
  map.logout '/logout', :controller => 'user/sessions', :action => 'destroy'
  map.forgot_password '/forgot_password', :controller => 'user/sessions', :action => 'forgot_password'
  map.send_password '/send_password', :controller => 'user/sessions', :action => 'send_new_password'
  
  map.namespace(:user) do |user|
    user.resources :sessions, :collection => { :token => :get, :send_new_password => :get, :forgot_password => :get }
  end
  
  map.namespace(:admin) do |admin|
    admin.login  '/login',  :controller => 'admin/sessions', :action => 'new'
    admin.logout '/logout', :controller => 'admin/sessions', :action => 'destroy'
    admin.resources :sessions, :collection => { :token => :get }
    admin.dashboard '/', :controller => 'nodes'

    admin.resources :users, :collection => { :admins => :get, :public => :get, :new_public => :get, :search => :get }

    admin.resources :nodes, 
      :member => { :place => :get },
      :collection => { :sort => :put }

    admin.resources :page_presets
    admin.resources :page_layouts
    admin.resources :contents
    admin.resources :content_modules
    admin.resources :registration_forms
    admin.resources :textfields, :collection => { :shared => :get }

    admin.resources :teasers, :collection => { :sort => :put }
    
    admin.resources :campaigns, :collection => { :search => :get }
    admin.resources :measure_points
    admin.conversions '/measure_points/:measure_point_id/conversions', :controller => 'conversions', :action => 'show'
    admin.resources :payments
    admin.resources :exports
    
    admin.resources :assets, :collection => { :search => :get, :incomplete => :get, :update_multiple => :put }
    admin.resources :asset_usages, :collection => { :sort => :put }
    admin.resources :tags, :collection => { :search => :get }
    
    admin.resources :page_collections do |page_collections|
      page_collections.resources :tag_collections
    end
    
    admin.resources :comments, :member => { :report_as_spam => :put, :report_as_ham => :put }, :collection => { :destroy_all_spam => :delete }
    
    admin.resources :pages, :collection => { :sort => :put }, :member => { :toggle => :put, :comments => :get } do |pages|
      pages.resources :contents, :collection => { :sort => :put }, :member => { :toggle => :put, :settings => :get }
      pages.resources :textfields
    end

    admin.registrations         '/registrations',               :controller => 'registrations', :action => 'index'
    admin.comment_registration  '/registrations/comment',       :controller => 'registrations', :action => 'comment'
    admin.registrations_by_type '/registrations/:type',         :controller => 'registrations', :action => 'index'
    admin.invalid_registrations_by_type '/registrations/:type/invalid', :controller => 'registrations', :action => 'invalid'
    admin.registration          '/registrations/:type/:id',     :controller => 'registrations', :action => 'show'
    admin.export_registration   '/registrations/export/:type.:format',  :controller => 'registrations', :action => 'period'
    
    admin.show_registration  '/registration/',       :controller => 'registrations', :action => 'show'
    admin.resources(:registrations, :collection => { :invalid => :get, :search => :get, :export => :get })
    
     
    admin.activities '/activities', :controller => 'activities', :action => 'index'
    admin.registration_activity '/activities/:type', :controller => 'activities', :action => 'show'
  end
end