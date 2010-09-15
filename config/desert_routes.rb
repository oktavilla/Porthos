ActionController::Routing::Routes.draw do |map|
  # Sample resource route with options:
  # map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  # map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.

  map.resources :registrations

  map.with_options :controller => 'assets', :action => 'show' do |asset|
    asset.resized_image  '/images/:size/:id.:format'
    asset.display_video  '/videos/:id.:format'
    asset.download_asset '/assets/:id.:format'
  end

  map.resources :pages, :member => { :preview => :get, :comment => :post }
  map.resources :page_collections
  
  map.login  '/login',  :controller => 'user/sessions', :action => 'new'
  map.logout '/logout', :controller => 'user/sessions', :action => 'destroy'
  map.forgot_password '/forgot_password', :controller => 'user/sessions', :action => 'forgot_password'
  map.send_password '/send_password', :controller => 'user/sessions', :action => 'send_new_password'
  
  map.new_user  '/skapa-konto',  :controller => 'user/users', :action => 'new'
  map.namespace(:user) do |user|
    user.resources :sessions, :collection => { :token => :get, :send_new_password => :get, :forgot_password => :get }
  end
  
  map.namespace(:admin) do |admin|
    admin.login  '/login',  :controller => 'admin/sessions', :action => 'new'
    admin.logout '/logout', :controller => 'admin/sessions', :action => 'destroy'
    admin.resources :sessions, :collection => { :token => :get }
    admin.dashboard '/', :controller => 'pages'

    admin.resources :users, :collection => { :admins => :get, :public => :get, :new_public => :get, :search => :get }

    admin.resources :nodes, 
      :member => { :place => :get },
      :collection => { :sort => :put }

    admin.resources :page_layouts

    admin.resources :field_sets do |field_sets|
      field_sets.resources :fields,
                           :collection => {
                             :sort => :put
                           }
    end

    admin.resources(:contents, {
      :collection => {
        :sort => :put
      },
      :member => {
        :toggle   => :put,
        :settings => :get
      }
    })
    admin.resources :content_modules
    admin.resources :registration_forms
    admin.resources :content_lists

    admin.resources :teasers, :collection => { :sort => :put }
    admin.resources :exports
    
    admin.resources :assets, :collection => { :search => :get, :incomplete => :get, :update_multiple => :put }
    admin.resources :asset_usages,
                    :collection => { :sort => :put }
    admin.resources :tags,
                    :collection => { :search => :get }
    
    admin.resources :page_collections do |page_collections|
      page_collections.resources :tag_collections
    end
    
    admin.resources :comments, :member => { :report_as_spam => :put, :report_as_ham => :put }, :collection => { :destroy_all_spam => :delete }
    
    admin.resources(:pages, {
      :collection => {
        :search => :get,
        :sort => :put
      },
      :member => {
        :toggle   => :put,
        :publish  => :put,
        :comments => :get
      }
    })

    admin.registrations         '/registrations',               :controller => 'registrations', :action => 'index'
    admin.comment_registration  '/registrations/comment',       :controller => 'registrations', :action => 'comment'
    admin.invalid_registrations_by_type '/registrations/:type/invalid', :controller => 'registrations', :action => 'invalid'
    admin.registration          '/registrations/:type/:id',     :controller => 'registrations', :action => 'show'
    admin.export_registration   '/registrations/export/:type.:format',  :controller => 'registrations', :action => 'period'
    
    admin.show_registration  '/registration/',       :controller => 'registrations', :action => 'show'
    admin.resources(:registrations, :collection => { :invalid => :get, :search => :get, :export => :get })
    
     
    admin.activities '/activities', :controller => 'activities', :action => 'index'
    admin.registration_activity '/activities/:type', :controller => 'activities', :action => 'show'
    
    admin.resources :redirects
  end
end