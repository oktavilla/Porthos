# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100914131159) do

  create_table "asset_usages", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gravity"
  end

  create_table "assets", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.string   "file_name"
    t.string   "mime_type"
    t.string   "extname"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "author"
    t.text     "description"
    t.integer  "created_by_id"
    t.integer  "parent_id"
    t.boolean  "private",       :default => false
  end

  add_index "assets", ["file_name"], :name => "index_assets_on_file_name"

  create_table "campaigns", :force => true do |t|
    t.string   "name"
    t.string   "dp_global_parent_code"
    t.string   "dp_buyer_code"
    t.string   "dp_donor_code"
    t.boolean  "active",                :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cart_items", :force => true do |t|
    t.integer  "cart_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "print_setting_id"
    t.integer  "min_quantity",     :default => 1
    t.boolean  "gift_wrapping"
  end

  add_index "cart_items", ["cart_id"], :name => "index_cart_items_on_cart_id"
  add_index "cart_items", ["product_id"], :name => "index_cart_items_on_product_id"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.string   "name"
    t.string   "email"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_address"
    t.string   "url"
    t.boolean  "spam",             :default => false
    t.float    "spaminess"
    t.string   "signature"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"

  create_table "content_images", :force => true do |t|
    t.integer  "image_asset_id"
    t.string   "title"
    t.text     "caption"
    t.string   "copyright"
    t.string   "style"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "downloadable",   :default => false
  end

  add_index "content_images", ["image_asset_id"], :name => "index_content_images_on_image_asset_id"

  create_table "content_lists", :force => true do |t|
    t.string   "name"
    t.string   "handle"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_lists", ["handle"], :name => "index_content_lists_on_handle"

  create_table "content_modules", :force => true do |t|
    t.string   "name"
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_videos", :force => true do |t|
    t.integer  "video_asset_id"
    t.string   "title"
    t.text     "caption"
    t.string   "copyright"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_videos", ["video_asset_id"], :name => "index_content_videos_on_video_asset_id"

  create_table "contents", :force => true do |t|
    t.integer  "context_id"
    t.integer  "column_position"
    t.integer  "position"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.string   "type"
    t.string   "accepting_content_resource_type"
    t.boolean  "active",                          :default => true, :null => false
    t.string   "context_type"
    t.integer  "restrictions_count"
  end

  add_index "contents", ["context_id"], :name => "index_contents_on_page_id"
  add_index "contents", ["parent_id"], :name => "index_contents_on_parent_id"
  add_index "contents", ["resource_id"], :name => "index_contents_on_resource_id"

  create_table "conversions", :force => true do |t|
    t.integer  "measure_point_id"
    t.integer  "registration_id"
    t.string   "registration_type"
    t.integer  "amount",            :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_associations", :force => true do |t|
    t.integer  "context_id"
    t.string   "context_type"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "relationship"
    t.integer  "field_id"
    t.string   "handle"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_associations", ["context_id", "context_type"], :name => "index_custom_associations_on_context_id_and_context_type"
  add_index "custom_associations", ["field_id"], :name => "index_custom_associations_on_field_id"
  add_index "custom_associations", ["handle"], :name => "index_custom_associations_on_handle"
  add_index "custom_associations", ["target_id", "target_type"], :name => "index_custom_associations_on_target_id_and_target_type"

  create_table "custom_attributes", :force => true do |t|
    t.string   "type"
    t.integer  "context_id"
    t.string   "context_type"
    t.integer  "field_id"
    t.string   "handle"
    t.string   "string_value"
    t.text     "text_value"
    t.datetime "date_time_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "custom_attributes", ["context_id", "context_type"], :name => "index_custom_attributes_on_context_id_and_context_type"
  add_index "custom_attributes", ["field_id"], :name => "index_custom_attributes_on_field_id"
  add_index "custom_attributes", ["handle"], :name => "index_custom_attributes_on_handle"

  create_table "exports", :force => true do |t|
    t.string   "registration_type"
    t.datetime "from"
    t.datetime "through"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "field_sets", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "handle"
    t.string   "template_name"
  end

  add_index "field_sets", ["handle"], :name => "index_field_sets_on_handle"

  create_table "fields", :force => true do |t|
    t.string   "type"
    t.integer  "field_set_id"
    t.string   "label"
    t.string   "handle"
    t.integer  "position"
    t.boolean  "required",              :default => false
    t.text     "instructions"
    t.boolean  "allow_rich_text",       :default => false
    t.integer  "association_source_id"
    t.string   "relationship"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fields", ["association_source_id"], :name => "index_fields_on_association_source_id"
  add_index "fields", ["field_set_id"], :name => "index_fields_on_field_set_id"

  create_table "measure_points", :force => true do |t|
    t.string   "name"
    t.integer  "link_type"
    t.integer  "target"
    t.integer  "cost",              :default => 0, :null => false
    t.string   "public_id"
    t.integer  "num_clicks",        :default => 0
    t.integer  "campaign_id"
    t.integer  "conversions_count", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "nodes", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.string   "slug"
    t.integer  "status",              :default => 0
    t.integer  "position"
    t.string   "controller"
    t.string   "action"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.integer  "field_set_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "children_count"
    t.boolean  "restricted",          :default => false
    t.string   "resource_class_name"
  end

  add_index "nodes", ["parent_id"], :name => "index_nodes_on_parent_id"
  add_index "nodes", ["resource_id"], :name => "index_nodes_on_resource_id"
  add_index "nodes", ["field_set_id"], :name => "index_nodes_on_field_set_id"
  add_index "nodes", ["slug"], :name => "index_nodes_on_slug"

  create_table "order_items", :force => true do |t|
    t.integer "order_id"
    t.integer "product_id"
    t.string  "name"
    t.string  "article_number"
    t.float   "vat"
    t.integer "quantity"
    t.integer "price",            :default => 0, :null => false
    t.integer "print_setting_id"
    t.boolean "gift_wrapping"
  end

  add_index "order_items", ["order_id"], :name => "index_order_items_on_order_id"
  add_index "order_items", ["product_id"], :name => "index_order_items_on_product_id"

  create_table "pages", :force => true do |t|
    t.integer  "field_set_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "slug"
    t.string   "title"
    t.text     "description"
    t.string   "layout_class"
    t.integer  "column_count"
    t.integer  "position"
    t.boolean  "active",                  :default => true
    t.boolean  "restricted",              :default => false
    t.text     "rendered_body"
    t.datetime "published_on"
    t.datetime "changed_at"
    t.datetime "changes_published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["field_set_id"], :name => "index_pages_on_field_set_id"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"

  create_table "payments", :force => true do |t|
    t.string   "payable_type"
    t.integer  "payable_id"
    t.boolean  "recurring"
    t.string   "billing_method"
    t.string   "transaction_id"
    t.string   "status"
    t.string   "response_message"
    t.integer  "amount",           :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "result_code"
  end

  create_table "payments_registration_comments", :id => false, :force => true do |t|
    t.integer  "payment_id"
    t.integer  "registration_comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payments_registration_comments", ["payment_id"], :name => "index_payments_registration_comments_on_payment_id"
  add_index "payments_registration_comments", ["registration_comment_id"], :name => "index_payments_registration_comments_on_registration_comment_id"

  create_table "plugin_schema_migrations", :id => false, :force => true do |t|
    t.string "plugin_name"
    t.string "version"
  end

  create_table "porthos_graphics", :force => true do |t|
    t.string   "title"
    t.string   "file_name"
    t.string   "mime_type"
    t.string   "extname"
    t.integer  "width"
    t.integer  "height"
    t.integer  "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "redirects", :force => true do |t|
    t.string   "path"
    t.string   "target"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redirects", ["path"], :name => "index_redirects_on_path"

  create_table "registration_comments", :force => true do |t|
    t.integer  "registration_id"
    t.text     "body"
    t.integer  "status"
    t.boolean  "fraud",                :default => false
    t.boolean  "updated_registration"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "registration_comments", ["registration_id"], :name => "index_registration_comments_on_registration_id"
  add_index "registration_comments", ["user_id"], :name => "index_registration_comments_on_user_id"

  create_table "registration_forms", :force => true do |t|
    t.integer  "contact_person_id"
    t.string   "name"
    t.string   "template"
    t.boolean  "send_email_response"
    t.boolean  "replyable_email"
    t.string   "reply_to_email"
    t.string   "email_subject"
    t.text     "email_body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "target_code"
    t.string   "default_amounts"
    t.integer  "notification_person_id"
    t.integer  "product_category_id"
  end

  create_table "registrations", :force => true do |t|
    t.string   "type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "customer_number"
    t.integer  "age"
    t.string   "email"
    t.string   "phone"
    t.string   "cell_phone"
    t.string   "organization"
    t.string   "department"
    t.string   "organization_number"
    t.string   "address"
    t.string   "post_code"
    t.string   "locality"
    t.string   "country"
    t.string   "shipping_address"
    t.string   "shipping_post_code"
    t.string   "shipping_locality"
    t.string   "shipping_country"
    t.boolean  "contact_approval"
    t.integer  "total_sum",                :default => 0,     :null => false
    t.integer  "total_vat",                :default => 0,     :null => false
    t.integer  "total_items"
    t.integer  "payment_id"
    t.string   "payment_type"
    t.string   "payment_transaction_id"
    t.string   "payment_status"
    t.string   "payment_response_message"
    t.string   "public_id"
    t.integer  "user_id"
    t.integer  "shop_id"
    t.string   "dispatch_id"
    t.string   "dispatch_status"
    t.string   "shipment_id"
    t.string   "shipment_type"
    t.text     "message"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "registration_form_id"
    t.integer  "donation",                 :default => 0,     :null => false
    t.integer  "shipment_price",           :default => 0,     :null => false
    t.integer  "activity_group_id"
    t.string   "school"
    t.string   "school_class"
    t.integer  "number_of_persons"
    t.string   "uri"
    t.string   "recipients"
    t.string   "target_code"
    t.integer  "shipment_vat",             :default => 0
    t.string   "shipping_organisation"
    t.integer  "discount_id"
    t.integer  "ecard_image_id"
    t.integer  "company_logo_id"
    t.string   "dp_campaign_code"
    t.string   "come_from"
    t.string   "shipping_first_name"
    t.string   "shipping_last_name"
    t.boolean  "non_gp_giver",             :default => false
    t.integer  "cart_id"
    t.string   "organization_type"
    t.string   "ip_address"
    t.string   "return_path"
    t.integer  "status",                   :default => 0
    t.boolean  "fraud",                    :default => false
    t.string   "session_id"
    t.string   "co_address"
    t.string   "shipping_co_address"
  end

  add_index "registrations", ["activity_group_id"], :name => "index_registrations_on_activity_group_id"
  add_index "registrations", ["cart_id"], :name => "index_registrations_on_cart_id"
  add_index "registrations", ["discount_id"], :name => "index_registrations_on_discount_id"
  add_index "registrations", ["dispatch_id"], :name => "index_registrations_on_dispatch_id"
  add_index "registrations", ["node_id"], :name => "index_registrations_on_node_id"
  add_index "registrations", ["payment_id"], :name => "index_registrations_on_payment_id"
  add_index "registrations", ["payment_transaction_id"], :name => "index_registrations_on_payment_transaction_id"
  add_index "registrations", ["public_id"], :name => "index_registrations_on_public_id"
  add_index "registrations", ["registration_form_id"], :name => "index_registrations_on_registration_form_id"
  add_index "registrations", ["shipment_id"], :name => "index_registrations_on_shipment_id"
  add_index "registrations", ["user_id"], :name => "index_registrations_on_user_id"

  create_table "restrictions", :force => true do |t|
    t.integer  "content_id"
    t.string   "mapping_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "restrictions", ["content_id"], :name => "index_restrictions_on_content_id"

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "settingable_type"
    t.string   "settingable_id"
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["name"], :name => "index_settings_on_name"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id"], :name => "index_taggings_on_taggable_id"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "content_teasers", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.string   "link"
    t.string   "parent_type"
    t.integer  "parent_id"
    t.integer  "image_asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_category_id"
    t.integer  "product_id"
    t.integer  "position"
    t.string   "css_class"
    t.string   "display_type"
    t.integer  "images_display_type", :default => 0
    t.string   "filter"
  end

  add_index "content_teasers", ["image_asset_id"], :name => "index_teasers_on_image_asset_id"
  add_index "content_teasers", ["parent_id"], :name => "index_teasers_on_resource_id"
  add_index "content_teasers", ["product_category_id"], :name => "index_teasers_on_product_category_id"
  add_index "content_teasers", ["product_id"], :name => "index_teasers_on_product_id"

  create_table "content_textfields", :force => true do |t|
    t.string   "filter"
    t.string   "class_name"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
  end

  add_index "user_roles", ["role_id"], :name => "index_user_roles_on_role_id"
  add_index "user_roles", ["user_id"], :name => "index_user_roles_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "login"
    t.string   "email"
    t.string   "phone"
    t.string   "cell_phone"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "avatar_id"
  end

  add_index "users", ["avatar_id"], :name => "index_users_on_avatar_id"

end
