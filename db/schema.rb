# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 97) do

  create_table "activity_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "asset_usages", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.integer  "created_by"
    t.integer  "incomplete",  :default => 0
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

  create_table "carts", :force => true do |t|
    t.integer  "shop_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "donation",    :default => 0
    t.boolean  "show_vat"
    t.integer  "discount_id"
  end

  add_index "carts", ["shop_id"], :name => "index_carts_on_shop_id"
  add_index "carts", ["discount_id"], :name => "index_carts_on_discount_id"

  create_table "content_images", :force => true do |t|
    t.integer  "image_asset_id"
    t.string   "title"
    t.text     "caption"
    t.string   "copyright"
    t.string   "style"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "content_images", ["image_asset_id"], :name => "index_content_images_on_image_asset_id"

  create_table "content_modules", :force => true do |t|
    t.string   "name"
    t.string   "template"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "available_in_page_type"
  end

  create_table "contents", :force => true do |t|
    t.integer  "page_id"
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
  end

  add_index "contents", ["page_id"], :name => "index_contents_on_page_id"
  add_index "contents", ["resource_id"], :name => "index_contents_on_resource_id"
  add_index "contents", ["parent_id"], :name => "index_contents_on_parent_id"

  create_table "conversions", :force => true do |t|
    t.integer  "measure_point_id"
    t.integer  "registration_id"
    t.string   "registration_type"
    t.integer  "amount",            :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_contents", :force => true do |t|
    t.integer  "position"
    t.integer  "column_position"
    t.integer  "page_layout_id"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "default_contents", ["page_layout_id"], :name => "index_default_contents_on_page_layout_id"
  add_index "default_contents", ["resource_id"], :name => "index_default_contents_on_resource_id"

  create_table "discounteds", :force => true do |t|
    t.integer  "discount_id"
    t.integer  "discountable_id"
    t.string   "discountable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discounteds", ["discount_id"], :name => "index_discounteds_on_discount_id"
  add_index "discounteds", ["discountable_id"], :name => "index_discounteds_on_discountable_id"

  create_table "discounts", :force => true do |t|
    t.integer  "shop_id"
    t.string   "name"
    t.string   "code"
    t.boolean  "free_shipping"
    t.float    "price_modification"
    t.datetime "valid_from"
    t.datetime "valid_through"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "discounts", ["shop_id"], :name => "index_discounts_on_shop_id"

  create_table "exports", :force => true do |t|
    t.string   "registration_type"
    t.datetime "from"
    t.datetime "through"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "global_parent_give_away_recipients", :force => true do |t|
    t.integer  "global_parent_give_away_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "post_code"
    t.string   "locality"
    t.string   "period"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "graphics", :force => true do |t|
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
  end

  create_table "nodes", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.string   "slug"
    t.integer  "status",                           :default => 0
    t.integer  "position"
    t.string   "controller"
    t.string   "action"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "children_count"
    t.integer  "restricted",          :limit => 1, :default => 0, :null => false
    t.string   "resource_class_name"
  end

  add_index "nodes", ["parent_id"], :name => "index_nodes_on_parent_id"
  add_index "nodes", ["resource_id"], :name => "index_nodes_on_resource_id"
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

  create_table "orders", :force => true do |t|
    t.integer  "shop_id"
    t.integer  "user_id"
    t.string   "public_id"
    t.integer  "type"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "cell_phone"
    t.string   "phone"
    t.string   "address"
    t.string   "post_code"
    t.string   "locality"
    t.string   "shipping_address"
    t.string   "shipping_post_code"
    t.string   "shipping_locality"
    t.integer  "total_items"
    t.string   "dispatch_id"
    t.string   "dispatch_status"
    t.string   "shipment_id"
    t.string   "shipment_type"
    t.string   "payment_type"
    t.string   "payment_transaction_id"
    t.string   "payment_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "customer_number"
    t.string   "payment_response_message"
    t.integer  "total_sum",                :default => 0
    t.integer  "total_vat",                :default => 0
    t.integer  "shipment_price",           :default => 0
    t.integer  "donation",                 :default => 0
    t.string   "organization"
    t.boolean  "contact_approval",         :default => false
  end

  add_index "orders", ["shop_id"], :name => "index_orders_on_shop_id"
  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"
  add_index "orders", ["dispatch_id"], :name => "index_orders_on_dispatch_id"
  add_index "orders", ["payment_transaction_id"], :name => "index_orders_on_payment_transaction_id"
  add_index "orders", ["public_id"], :name => "index_orders_on_public_id"

  create_table "page_layouts", :force => true do |t|
    t.string   "css_id"
    t.string   "name"
    t.integer  "columns",    :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_presets", :force => true do |t|
    t.integer  "graphic_id"
    t.string   "name"
    t.string   "description"
    t.integer  "page_collection_id"
    t.integer  "page_layout_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "page_layout_id"
    t.string   "layout_class"
    t.integer  "column_count"
    t.datetime "published_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "type"
    t.integer  "position"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "default_child_layout_id"
    t.boolean  "active",                  :default => true, :null => false
  end

  add_index "pages", ["page_layout_id"], :name => "index_pages_on_page_layout_id"
  add_index "pages", ["slug"], :name => "index_pages_on_slug"
  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["default_child_layout_id"], :name => "index_pages_on_default_child_layout_id"

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

  create_table "plugin_schema_info", :id => false, :force => true do |t|
    t.string  "plugin_name"
    t.integer "version"
  end

  create_table "print_settings", :force => true do |t|
    t.string   "predef_greeting"
    t.string   "greeting_text"
    t.string   "greeting_font"
    t.string   "logo_file_name"
    t.string   "signature_file_name"
    t.string   "delivery_date"
    t.string   "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "greeting_color",      :default => "Svart"
    t.string   "logo_color",          :default => "Svart"
  end

  create_table "product_categories", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "parent_id"
    t.integer  "shop_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",     :default => 0
  end

  add_index "product_categories", ["slug"], :name => "index_product_categories_on_slug"
  add_index "product_categories", ["parent_id"], :name => "index_product_categories_on_parent_id"
  add_index "product_categories", ["shop_id"], :name => "index_product_categories_on_shop_id"

  create_table "product_categorizations", :force => true do |t|
    t.integer  "product_category_id"
    t.integer  "product_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "min_quantity",        :default => 1
  end

  add_index "product_categorizations", ["product_category_id"], :name => "index_product_categorizations_on_product_category_id"
  add_index "product_categorizations", ["product_id"], :name => "index_product_categorizations_on_product_id"

  create_table "product_images", :force => true do |t|
    t.integer  "asset_id"
    t.integer  "product_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "product_images", ["asset_id"], :name => "index_product_images_on_asset_id"
  add_index "product_images", ["product_id"], :name => "index_product_images_on_product_id"

  create_table "products", :force => true do |t|
    t.string   "name"
    t.text     "short_description"
    t.text     "long_description"
    t.string   "article_number"
    t.float    "vat"
    t.integer  "quantity"
    t.boolean  "hidden",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "eta"
    t.integer  "price",             :default => 0,     :null => false
    t.boolean  "printable",         :default => false
  end

  add_index "products", ["article_number"], :name => "index_products_on_article_number"

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
    t.integer  "shipment_price",           :default => 0,     :null => false
    t.string   "message"
    t.integer  "node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "registration_form_id"
    t.integer  "donation",                 :default => 0,     :null => false
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
  end

  add_index "registrations", ["payment_id"], :name => "index_registrations_on_payment_id"
  add_index "registrations", ["payment_transaction_id"], :name => "index_registrations_on_payment_transaction_id"
  add_index "registrations", ["public_id"], :name => "index_registrations_on_public_id"
  add_index "registrations", ["user_id"], :name => "index_registrations_on_user_id"
  add_index "registrations", ["dispatch_id"], :name => "index_registrations_on_dispatch_id"
  add_index "registrations", ["shipment_id"], :name => "index_registrations_on_shipment_id"
  add_index "registrations", ["node_id"], :name => "index_registrations_on_node_id"
  add_index "registrations", ["registration_form_id"], :name => "index_registrations_on_registration_form_id"
  add_index "registrations", ["activity_group_id"], :name => "index_registrations_on_activity_group_id"
  add_index "registrations", ["discount_id"], :name => "index_registrations_on_discount_id"
  add_index "registrations", ["cart_id"], :name => "index_registrations_on_cart_id"

  create_table "sample_product_order_items", :force => true do |t|
    t.integer  "sample_product_order_id"
    t.string   "article_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sample_product_order_items", ["sample_product_order_id"], :name => "index_sample_product_order_items_on_sample_product_order_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shipments", :force => true do |t|
    t.integer  "order_id"
    t.integer  "dispatch_id"
    t.string   "dispatch_status"
    t.string   "package_id"
    t.string   "package_type"
    t.integer  "price",                  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "dispatch_full_response"
    t.text     "distribution_post_vars"
    t.integer  "vat",                    :default => 0
  end

  add_index "shipments", ["order_id"], :name => "index_shipments_on_order_id"

  create_table "shops", :force => true do |t|
    t.string   "name"
    t.string   "slug"
    t.boolean  "show_vat",                :default => true
    t.boolean  "closed",                  :default => false
    t.text     "message"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_printable",         :default => false
    t.integer  "default_child_layout_id"
  end

  add_index "shops", ["default_child_layout_id"], :name => "index_shops_on_default_child_layout_id"

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

  create_table "teasers", :force => true do |t|
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
  end

  add_index "teasers", ["parent_id"], :name => "index_teasers_on_resource_id"
  add_index "teasers", ["image_asset_id"], :name => "index_teasers_on_image_asset_id"
  add_index "teasers", ["product_category_id"], :name => "index_teasers_on_product_category_id"
  add_index "teasers", ["product_id"], :name => "index_teasers_on_product_id"

  create_table "textfields", :force => true do |t|
    t.boolean  "shared",     :default => false
    t.string   "filter"
    t.string   "class_name"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "tracking_points", :force => true do |t|
    t.string   "name"
    t.string   "template"
    t.string   "parent_type"
    t.string   "parent_id"
    t.string   "event"
    t.string   "checksum"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.boolean  "admin",                                   :default => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "login"
    t.string   "email"
    t.string   "phone"
    t.string   "cellphone"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.integer  "avatar_id"
    t.string   "type"
  end

  add_index "users", ["avatar_id"], :name => "index_users_on_avatar_id"

  create_table "vg_cart_items", :force => true do |t|
    t.integer  "vg_cart_id"
    t.string   "name"
    t.integer  "price"
    t.integer  "quantity"
    t.integer  "virtual_gift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vg_cart_items", ["vg_cart_id"], :name => "index_vg_cart_items_on_vg_cart_id"
  add_index "vg_cart_items", ["virtual_gift_id"], :name => "index_vg_cart_items_on_virtual_gift_id"

  create_table "vg_carts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vg_categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vg_categorizations", :force => true do |t|
    t.integer  "vg_category_id"
    t.integer  "virtual_gift_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "vg_categorizations", ["vg_category_id"], :name => "index_vg_categorizations_on_vg_category_id"
  add_index "vg_categorizations", ["virtual_gift_id"], :name => "index_vg_categorizations_on_virtual_gift_id"

  create_table "virtual_gifts", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "price",       :default => 0
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
