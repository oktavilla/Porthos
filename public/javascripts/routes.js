var Routes = {
  formatted_admin_session: function(id, format) {
    return '/admin/sessions/'+id+'.'+format+'';
  },

  formatted_admin_registration_form: function(id, format) {
    return '/admin/registration_forms/'+id+'.'+format+'';
  },

  new_admin_payment: function() {
    return '/admin/payments/new';
  },

  pages: function() {
    return '/pages';
  },

  new_page_collection: function() {
    return '/page_collections/new';
  },

  admin_exports: function() {
    return '/admin/exports';
  },

  new_public_admin_users: function() {
    return '/admin/users/new_public';
  },

  formatted_new_admin_textfield: function(format) {
    return '/admin/textfields/new.'+format+'';
  },

  formatted_sort_admin_teasers: function(format) {
    return '/admin/teasers/sort.'+format+'';
  },

  admin_export: function(id) {
    return '/admin/exports/'+id+'';
  },

  edit_admin_user: function(id) {
    return '/admin/users/'+id+'/edit';
  },

  update_multiple_admin_assets: function() {
    return '/admin/assets/update_multiple';
  },

  edit_payment: function(id) {
    return '/payments/'+id+'/edit';
  },

  admin_nodes: function() {
    return '/admin/nodes';
  },

  formatted_edit_admin_teaser: function(id, format) {
    return '/admin/teasers/'+id+'/edit.'+format+'';
  },

  edit_admin_page_content: function(page_id, id) {
    return '/admin/pages/'+page_id+'/contents/'+id+'/edit';
  },

  formatted_new_admin_campaign: function(format) {
    return '/admin/campaigns/new.'+format+'';
  },

  edit_admin_asset: function(id) {
    return '/admin/assets/'+id+'/edit';
  },

  place_admin_node: function(id) {
    return '/admin/nodes/'+id+'/place';
  },

  admin_page_textfields: function(page_id) {
    return '/admin/pages/'+page_id+'/textfields';
  },

  admin_asset_usages: function() {
    return '/admin/asset_usages';
  },

  formatted_page: function(id, format) {
    return '/pages/'+id+'.'+format+'';
  },

  page: function(id) {
    return '/pages/'+id+'';
  },

  new_admin_page_preset: function() {
    return '/admin/page_presets/new';
  },

  formatted_admin_measure_points: function(format) {
    return '/admin/measure_points.'+format+'';
  },

  admin_page_textfield: function(page_id, id) {
    return '/admin/pages/'+page_id+'/textfields/'+id+'';
  },

  formatted_admin_measure_point: function(id, format) {
    return '/admin/measure_points/'+id+'.'+format+'';
  },

  admin_asset_usage: function(id) {
    return '/admin/asset_usages/'+id+'';
  },

  admin_page_layouts: function() {
    return '/admin/page_layouts';
  },

  admin_export_registration: function(type, format) {
    return '/admin/registrations/export/'+type+'.'+format+'';
  },

  admin_page_layout: function(id) {
    return '/admin/page_layouts/'+id+'';
  },

  edit_admin_page_collection: function(id) {
    return '/admin/page_collections/'+id+'/edit';
  },

  token_user_sessions: function() {
    return '/user/sessions/token';
  },

  admin_pages: function() {
    return '/admin/pages';
  },

  user_sessions: function() {
    return '/user/sessions';
  },

  edit_admin_content: function(id) {
    return '/admin/contents/'+id+'/edit';
  },

  toggle_admin_page: function(id) {
    return '/admin/pages/'+id+'/toggle';
  },

  login: function() {
    return '/login';
  },

  new_admin_content_module: function() {
    return '/admin/content_modules/new';
  },

  user_session: function(id) {
    return '/user/sessions/'+id+'';
  },

  edit_page: function(id) {
    return '/pages/'+id+'/edit';
  },

  admin_sessions: function() {
    return '/admin/sessions';
  },

  admin_registration_forms: function() {
    return '/admin/registration_forms';
  },

  admin_registration_form: function(id) {
    return '/admin/registration_forms/'+id+'';
  },

  formatted_admin_payments: function(format) {
    return '/admin/payments.'+format+'';
  },

  payments: function() {
    return '/payments';
  },

  admin_session: function(id) {
    return '/admin/sessions/'+id+'';
  },

  formatted_admins_admin_users: function(format) {
    return '/admin/users/admins.'+format+'';
  },

  new_admin_textfield: function() {
    return '/admin/textfields/new';
  },

  formatted_page_collections: function(format) {
    return '/page_collections.'+format+'';
  },

  formatted_admin_payment: function(id, format) {
    return '/admin/payments/'+id+'.'+format+'';
  },

  sort_admin_teasers: function() {
    return '/admin/teasers/sort';
  },

  formatted_page_collection: function(id, format) {
    return '/page_collections/'+id+'.'+format+'';
  },

  formatted_edit_admin_export: function(id, format) {
    return '/admin/exports/'+id+'/edit.'+format+'';
  },

  formatted_new_admin_user: function(format) {
    return '/admin/users/new.'+format+'';
  },

  formatted_sort_admin_nodes: function(format) {
    return '/admin/nodes/sort.'+format+'';
  },

  edit_admin_teaser: function(id) {
    return '/admin/teasers/'+id+'/edit';
  },

  formatted_incomplete_admin_assets: function(format) {
    return '/admin/assets/incomplete.'+format+'';
  },

  formatted_new_payment: function(format) {
    return '/payments/new.'+format+'';
  },

  formatted_new_admin_page_content: function(page_id, format) {
    return '/admin/pages/'+page_id+'/contents/new.'+format+'';
  },

  formatted_new_admin_asset: function(format) {
    return '/admin/assets/new.'+format+'';
  },

  formatted_edit_admin_node: function(id, format) {
    return '/admin/nodes/'+id+'/edit.'+format+'';
  },

  new_admin_campaign: function() {
    return '/admin/campaigns/new';
  },

  formatted_admin_page_content: function(page_id, id, format) {
    return '/admin/pages/'+page_id+'/contents/'+id+'.'+format+'';
  },

  formatted_admin_page_presets: function(format) {
    return '/admin/page_presets.'+format+'';
  },

  admin_measure_points: function() {
    return '/admin/measure_points';
  },

  registration: function(id) {
    return '/registrations/'+id+'';
  },

  formatted_sort_admin_asset_usages: function(format) {
    return '/admin/asset_usages/sort.'+format+'';
  },

  formatted_edit_admin_page_textfield: function(page_id, id, format) {
    return '/admin/pages/'+page_id+'/textfields/'+id+'/edit.'+format+'';
  },

  formatted_edit_admin_asset_usage: function(id, format) {
    return '/admin/asset_usages/'+id+'/edit.'+format+'';
  },

  formatted_admin_page_preset: function(id, format) {
    return '/admin/page_presets/'+id+'.'+format+'';
  },

  admin_measure_point: function(id) {
    return '/admin/measure_points/'+id+'';
  },

  admin_registration: function(type, id) {
    return '/admin/registrations/'+type+'/'+id+'';
  },

  formatted_edit_admin_page_layout: function(id, format) {
    return '/admin/page_layouts/'+id+'/edit.'+format+'';
  },

  forgot_password: function() {
    return '/forgot_password';
  },

  formatted_new_admin_page_collection: function(format) {
    return '/admin/page_collections/new.'+format+'';
  },

  formatted_sort_admin_pages: function(format) {
    return '/admin/pages/sort.'+format+'';
  },

  formatted_send_new_password_user_sessions: function(format) {
    return '/user/sessions/send_new_password.'+format+'';
  },

  formatted_new_admin_content: function(format) {
    return '/admin/contents/new.'+format+'';
  },

  formatted_edit_admin_page: function(id, format) {
    return '/admin/pages/'+id+'/edit.'+format+'';
  },

  formatted_edit_user_session: function(id, format) {
    return '/user/sessions/'+id+'/edit.'+format+'';
  },

  formatted_new_page: function(format) {
    return '/pages/new.'+format+'';
  },

  display_image: function(size, id, format) {
    return '/images/'+size+'/'+id+'.'+format+'';
  },

  formatted_admin_content_modules: function(format) {
    return '/admin/content_modules.'+format+'';
  },

  formatted_token_admin_sessions: function(format) {
    return '/admin/sessions/token.'+format+'';
  },

  formatted_admin_content_module: function(id, format) {
    return '/admin/content_modules/'+id+'.'+format+'';
  },

  payment: function(id) {
    return '/payments/'+id+'';
  },

  admin_payments: function() {
    return '/admin/payments';
  },

  formatted_edit_admin_session: function(id, format) {
    return '/admin/sessions/'+id+'/edit.'+format+'';
  },

  formatted_edit_registration: function(id, format) {
    return '/registrations/'+id+'/edit.'+format+'';
  },

  formatted_edit_admin_registration_form: function(id, format) {
    return '/admin/registration_forms/'+id+'/edit.'+format+'';
  },

  admins_admin_users: function() {
    return '/admin/users/admins';
  },

  formatted_admin_textfields: function(format) {
    return '/admin/textfields.'+format+'';
  },

  admin_payment: function(id) {
    return '/admin/payments/'+id+'';
  },

  page_collection: function(id) {
    return '/page_collections/'+id+'';
  },

  edit_admin_export: function(id) {
    return '/admin/exports/'+id+'/edit';
  },

  new_admin_user: function() {
    return '/admin/users/new';
  },

  formatted_admin_textfield: function(id, format) {
    return '/admin/textfields/'+id+'.'+format+'';
  },

  formatted_new_admin_teaser: function(format) {
    return '/admin/teasers/new.'+format+'';
  },

  incomplete_admin_assets: function() {
    return '/admin/assets/incomplete';
  },

  new_payment: function() {
    return '/payments/new';
  },

  sort_admin_nodes: function() {
    return '/admin/nodes/sort';
  },

  new_admin_page_content: function(page_id) {
    return '/admin/pages/'+page_id+'/contents/new';
  },

  new_admin_asset: function() {
    return '/admin/assets/new';
  },

  edit_admin_node: function(id) {
    return '/admin/nodes/'+id+'/edit';
  },

  formatted_admin_campaigns: function(format) {
    return '/admin/campaigns.'+format+'';
  },

  admin_page_content: function(page_id, id) {
    return '/admin/pages/'+page_id+'/contents/'+id+'';
  },

  formatted_admin_campaign: function(id, format) {
    return '/admin/campaigns/'+id+'.'+format+'';
  },

  sort_admin_asset_usages: function() {
    return '/admin/asset_usages/sort';
  },

  admin_page_presets: function() {
    return '/admin/page_presets';
  },

  edit_admin_page_textfield: function(page_id, id) {
    return '/admin/pages/'+page_id+'/textfields/'+id+'/edit';
  },

  admin_page_preset: function(id) {
    return '/admin/page_presets/'+id+'';
  },

  formatted_edit_admin_measure_point: function(id, format) {
    return '/admin/measure_points/'+id+'/edit.'+format+'';
  },

  edit_admin_asset_usage: function(id) {
    return '/admin/asset_usages/'+id+'/edit';
  },

  admin_invalid_registrations_by_type: function(type) {
    return '/admin/registrations/'+type+'/invalid';
  },

  new_admin_page_collection: function() {
    return '/admin/page_collections/new';
  },

  formatted_registration: function(id, format) {
    return '/registrations/'+id+'.'+format+'';
  },

  edit_admin_page_layout: function(id) {
    return '/admin/page_layouts/'+id+'/edit';
  },

  new_admin_content: function() {
    return '/admin/contents/new';
  },

  sort_admin_pages: function() {
    return '/admin/pages/sort';
  },

  send_new_password_user_sessions: function() {
    return '/user/sessions/send_new_password';
  },

  edit_admin_page: function(id) {
    return '/admin/pages/'+id+'/edit';
  },

  edit_user_session: function(id) {
    return '/user/sessions/'+id+'/edit';
  },

  new_page: function() {
    return '/pages/new';
  },

  admin_content_modules: function() {
    return '/admin/content_modules';
  },

  sort_admin_page_contents: function(page_id) {
    return '/admin/pages/'+page_id+'/contents/sort';
  },

  admin_content_module: function(id) {
    return '/admin/content_modules/'+id+'';
  },

  token_admin_sessions: function() {
    return '/admin/sessions/token';
  },

  edit_admin_session: function(id) {
    return '/admin/sessions/'+id+'/edit';
  },

  edit_registration: function(id) {
    return '/registrations/'+id+'/edit';
  },

  edit_admin_registration_form: function(id) {
    return '/admin/registration_forms/'+id+'/edit';
  },

  admin_textfields: function() {
    return '/admin/textfields';
  },

  formatted_edit_admin_payment: function(id, format) {
    return '/admin/payments/'+id+'/edit.'+format+'';
  },

  formatted_public_admin_users: function(format) {
    return '/admin/users/public.'+format+'';
  },

  formatted_admin_users: function(format) {
    return '/admin/users.'+format+'';
  },

  admin_textfield: function(id) {
    return '/admin/textfields/'+id+'';
  },

  formatted_edit_page_collection: function(id, format) {
    return '/page_collections/'+id+'/edit.'+format+'';
  },

  formatted_new_admin_export: function(format) {
    return '/admin/exports/new.'+format+'';
  },

  formatted_search_admin_assets: function(format) {
    return '/admin/assets/search.'+format+'';
  },

  formatted_payments: function(format) {
    return '/payments.'+format+'';
  },

  formatted_admin_user: function(id, format) {
    return '/admin/users/'+id+'.'+format+'';
  },

  new_admin_teaser: function() {
    return '/admin/teasers/new';
  },

  formatted_admin_page_contents: function(page_id, format) {
    return '/admin/pages/'+page_id+'/contents.'+format+'';
  },

  formatted_new_admin_node: function(format) {
    return '/admin/nodes/new.'+format+'';
  },

  admin_campaigns: function() {
    return '/admin/campaigns';
  },

  formatted_admin_assets: function(format) {
    return '/admin/assets.'+format+'';
  },

  formatted_toggle_admin_page_content: function(page_id, id, format) {
    return '/admin/pages/'+page_id+'/contents/'+id+'/toggle.'+format+'';
  },

  formatted_admin_asset: function(id, format) {
    return '/admin/assets/'+id+'.'+format+'';
  },

  page_collections: function() {
    return '/page_collections';
  },

  formatted_admin_node: function(id, format) {
    return '/admin/nodes/'+id+'.'+format+'';
  },

  admin_campaign: function(id) {
    return '/admin/campaigns/'+id+'';
  },

  formatted_new_admin_page_textfield: function(page_id, format) {
    return '/admin/pages/'+page_id+'/textfields/new.'+format+'';
  },

  formatted_edit_admin_page_preset: function(id, format) {
    return '/admin/page_presets/'+id+'/edit.'+format+'';
  },

  edit_admin_measure_point: function(id) {
    return '/admin/measure_points/'+id+'/edit';
  },

  formatted_new_admin_asset_usage: function(format) {
    return '/admin/asset_usages/new.'+format+'';
  },

  admin_registrations_by_type: function(type) {
    return '/admin/registrations/'+type+'';
  },

  formatted_admin_page_collections: function(format) {
    return '/admin/page_collections.'+format+'';
  },

  formatted_new_admin_page_layout: function(format) {
    return '/admin/page_layouts/new.'+format+'';
  },

  registrations: function() {
    return '/registrations';
  },

  formatted_admin_page_collection: function(id, format) {
    return '/admin/page_collections/'+id+'.'+format+'';
  },

  formatted_forgot_password_user_sessions: function(format) {
    return '/user/sessions/forgot_password.'+format+'';
  },

  formatted_admin_contents: function(format) {
    return '/admin/contents.'+format+'';
  },

  formatted_new_admin_page: function(format) {
    return '/admin/pages/new.'+format+'';
  },

  formatted_new_user_session: function(format) {
    return '/user/sessions/new.'+format+'';
  },

  formatted_pages: function(format) {
    return '/pages.'+format+'';
  },

  formatted_admin_content: function(id, format) {
    return '/admin/contents/'+id+'.'+format+'';
  },

  formatted_admin_page: function(id, format) {
    return '/admin/pages/'+id+'.'+format+'';
  },

  admin_logout: function() {
    return '/admin/logout';
  },

  formatted_edit_admin_content_module: function(id, format) {
    return '/admin/content_modules/'+id+'/edit.'+format+'';
  },

  formatted_new_admin_session: function(format) {
    return '/admin/sessions/new.'+format+'';
  },

  formatted_new_registration: function(format) {
    return '/registrations/new.'+format+'';
  },

  formatted_new_admin_registration_form: function(format) {
    return '/admin/registration_forms/new.'+format+'';
  },

  edit_admin_payment: function(id) {
    return '/admin/payments/'+id+'/edit';
  },

  public_admin_users: function() {
    return '/admin/users/public';
  },

  formatted_shared_admin_textfields: function(format) {
    return '/admin/textfields/shared.'+format+'';
  },

  formatted_edit_admin_textfield: function(id, format) {
    return '/admin/textfields/'+id+'/edit.'+format+'';
  },

  edit_page_collection: function(id) {
    return '/page_collections/'+id+'/edit';
  },

  new_admin_export: function() {
    return '/admin/exports/new';
  },

  admin_users: function() {
    return '/admin/users';
  },

  search_admin_assets: function() {
    return '/admin/assets/search';
  },

  admin_user: function(id) {
    return '/admin/users/'+id+'';
  },

  logout: function() {
    return '/logout';
  },

  formatted_admin_teasers: function(format) {
    return '/admin/teasers.'+format+'';
  },

  admin_page_contents: function(page_id) {
    return '/admin/pages/'+page_id+'/contents';
  },

  formatted_admin_teaser: function(id, format) {
    return '/admin/teasers/'+id+'.'+format+'';
  },

  admin_assets: function() {
    return '/admin/assets';
  },

  new_admin_node: function() {
    return '/admin/nodes/new';
  },

  toggle_admin_page_content: function(page_id, id) {
    return '/admin/pages/'+page_id+'/contents/'+id+'/toggle';
  },

  admin_asset: function(id) {
    return '/admin/assets/'+id+'';
  },

  admin_node: function(id) {
    return '/admin/nodes/'+id+'';
  },

  formatted_edit_admin_campaign: function(id, format) {
    return '/admin/campaigns/'+id+'/edit.'+format+'';
  },

  new_admin_page_textfield: function(page_id) {
    return '/admin/pages/'+page_id+'/textfields/new';
  },

  formatted_new_admin_measure_point: function(format) {
    return '/admin/measure_points/new.'+format+'';
  },

  new_admin_asset_usage: function() {
    return '/admin/asset_usages/new';
  },

  edit_admin_page_preset: function(id) {
    return '/admin/page_presets/'+id+'/edit';
  },

  admin_registrations: function() {
    return '/admin/registrations';
  },

  new_admin_page_layout: function() {
    return '/admin/page_layouts/new';
  },

  admin_page_collections: function() {
    return '/admin/page_collections';
  },

  admin_registration_activity: function(type) {
    return '/admin/activities/'+type+'';
  },

  admin_page_collection: function(id) {
    return '/admin/page_collections/'+id+'';
  },

  forgot_password_user_sessions: function() {
    return '/user/sessions/forgot_password';
  },

  admin_contents: function() {
    return '/admin/contents';
  },

  admin_content: function(id) {
    return '/admin/contents/'+id+'';
  },

  new_admin_page: function() {
    return '/admin/pages/new';
  },

  new_user_session: function() {
    return '/user/sessions/new';
  },

  admin_page: function(id) {
    return '/admin/pages/'+id+'';
  },

  admin_login: function() {
    return '/admin/login';
  },

  edit_admin_content_module: function(id) {
    return '/admin/content_modules/'+id+'/edit';
  },

  new_admin_registration_form: function() {
    return '/admin/registration_forms/new';
  },

  new_admin_session: function() {
    return '/admin/sessions/new';
  },

  new_registration: function() {
    return '/registrations/new';
  },

  admin_dashboard: function() {
    return '/admin';
  },

  shared_admin_textfields: function() {
    return '/admin/textfields/shared';
  },

  formatted_new_admin_payment: function(format) {
    return '/admin/payments/new.'+format+'';
  },

  send_password: function() {
    return '/send_password';
  },

  edit_admin_textfield: function(id) {
    return '/admin/textfields/'+id+'/edit';
  },

  formatted_new_page_collection: function(format) {
    return '/page_collections/new.'+format+'';
  },

  formatted_admin_exports: function(format) {
    return '/admin/exports.'+format+'';
  },

  formatted_new_public_admin_users: function(format) {
    return '/admin/users/new_public.'+format+'';
  },

  formatted_edit_admin_user: function(id, format) {
    return '/admin/users/'+id+'/edit.'+format+'';
  },

  download_asset: function(id, format) {
    return '/assets/'+id+'.'+format+'';
  },

  admin_teasers: function() {
    return '/admin/teasers';
  },

  formatted_admin_export: function(id, format) {
    return '/admin/exports/'+id+'.'+format+'';
  },

  formatted_sort_admin_page_contents: function(page_id, format) {
    return '/admin/pages/'+page_id+'/contents/sort.'+format+'';
  },

  formatted_update_multiple_admin_assets: function(format) {
    return '/admin/assets/update_multiple.'+format+'';
  },

  formatted_edit_payment: function(id, format) {
    return '/payments/'+id+'/edit.'+format+'';
  },

  formatted_admin_nodes: function(format) {
    return '/admin/nodes.'+format+'';
  },

  admin_teaser: function(id) {
    return '/admin/teasers/'+id+'';
  },

  formatted_edit_admin_page_content: function(page_id, id, format) {
    return '/admin/pages/'+page_id+'/contents/'+id+'/edit.'+format+'';
  },

  formatted_place_admin_node: function(id, format) {
    return '/admin/nodes/'+id+'/place.'+format+'';
  },

  edit_admin_campaign: function(id) {
    return '/admin/campaigns/'+id+'/edit';
  },

  formatted_edit_admin_asset: function(id, format) {
    return '/admin/assets/'+id+'/edit.'+format+'';
  },

  formatted_admin_page_textfields: function(page_id, format) {
    return '/admin/pages/'+page_id+'/textfields.'+format+'';
  },

  formatted_admin_asset_usages: function(format) {
    return '/admin/asset_usages.'+format+'';
  },

  formatted_new_admin_page_preset: function(format) {
    return '/admin/page_presets/new.'+format+'';
  },

  new_admin_measure_point: function() {
    return '/admin/measure_points/new';
  },

  formatted_admin_page_textfield: function(page_id, id, format) {
    return '/admin/pages/'+page_id+'/textfields/'+id+'.'+format+'';
  },

  formatted_admin_page_layouts: function(format) {
    return '/admin/page_layouts.'+format+'';
  },

  admin_conversions: function(measure_point_id) {
    return '/admin/measure_points/'+measure_point_id+'/conversions';
  },

  formatted_admin_asset_usage: function(id, format) {
    return '/admin/asset_usages/'+id+'.'+format+'';
  },

  admin_activities: function() {
    return '/admin/activities';
  },

  formatted_edit_admin_page_collection: function(id, format) {
    return '/admin/page_collections/'+id+'/edit.'+format+'';
  },

  formatted_token_user_sessions: function(format) {
    return '/user/sessions/token.'+format+'';
  },

  formatted_admin_page_layout: function(id, format) {
    return '/admin/page_layouts/'+id+'.'+format+'';
  },

  formatted_admin_pages: function(format) {
    return '/admin/pages.'+format+'';
  },

  formatted_user_sessions: function(format) {
    return '/user/sessions.'+format+'';
  },

  formatted_edit_admin_content: function(id, format) {
    return '/admin/contents/'+id+'/edit.'+format+'';
  },

  formatted_toggle_admin_page: function(id, format) {
    return '/admin/pages/'+id+'/toggle.'+format+'';
  },

  formatted_user_session: function(id, format) {
    return '/user/sessions/'+id+'.'+format+'';
  },

  formatted_edit_page: function(id, format) {
    return '/pages/'+id+'/edit.'+format+'';
  },

  formatted_new_admin_content_module: function(format) {
    return '/admin/content_modules/new.'+format+'';
  },

  formatted_payment: function(id, format) {
    return '/payments/'+id+'.'+format+'';
  },

  formatted_admin_sessions: function(format) {
    return '/admin/sessions.'+format+'';
  },

  formatted_registrations: function(format) {
    return '/registrations.'+format+'';
  },

  formatted_admin_registration_forms: function(format) {
    return '/admin/registration_forms.'+format+'';
  },

};