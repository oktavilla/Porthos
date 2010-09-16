# Create default admin user

admin_role = Role.create(:name => 'Admin')
public_role = Role.create(:name => 'Public')
site_admin_role = Role.create(:name => 'SiteAdmin')
admin_user = User.create(:login => 'admin', :password => 'password', :password_confirmation => 'password', :first_name => 'Admin', :last_name => 'Admin', :email => 'admin@example.com')
UserRole.create(:role_id => admin_role.id, :user_id => admin_user.id)
UserRole.create(:role_id => site_admin_role.id, :user_id => admin_user.id)

# Create default fieldset

start_fieldset = FieldSet.create!(:title => 'Start', :handle => 'start')
article_fieldset = FieldSet.create!(:title => 'Artikel', :handle => 'article')


# Create pages
start_page = Page.create!({
  :title => 'Start',
  :parent_type => 'Page', 
  :active => 1, 
  :created_by => admin_user,
  :field_set_id => start_fieldset.id
})
start_node = Node.create!({
  :name => 'Start', 
  :status => 1, 
  :controller => 'pages', 
  :action => 'show',
  :resource_type => 'Page',
  :resource_id => start_page.id,
  :field_set_id => start_fieldset.id
})
article_page = Page.create!({
  :title => 'Artikel 1', 
  :parent_type => 'Page', 
  :active => 1, 
  :created_by => admin_user,
  :field_set_id => article_fieldset.id
})
Node.create!({
  :parent_id => start_node.id,
  :name => 'Artikel 1', 
  :status => 1, 
  :controller => 'pages', 
  :action => 'show',
  :resource_type => 'Page',
  :resource_id => article_page.id,
  :field_set_id => article_fieldset.id
})