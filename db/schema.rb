ActiveRecord::Migration.create_table "yacc_route", :primary_key => "route_id", :force => true do |t|
  t.integer  "app_id",                                                         :null => false
  t.string   "route_name",              :limit => 64,                          :null => false
  t.integer  "day_of_week",                                                    :null => false
  t.integer  "begin_time",                                                     :null => false
  t.integer  "end_time",                                                       :null => false
  t.string   "destid",                  :limit => 64,                          :null => false
  t.integer  "distribution_percentage",                                        :null => false
  t.datetime "created_at"
  t.datetime "updated_at" 
end

ActiveRecord::Migration.create_table "recordings", :primary_key => "recording_id", :force => true do |t|
  t.string   "keyword",    :limit => 2048
  t.datetime "start_time"
  t.integer  "duration",                   :null => false
  t.integer  "owner_id"
  t.integer  "app_id"
  t.integer  "job_id"
end

ActiveRecord::Migration.create_table "yacc_route_destination_xref", :primary_key => "route_destination_xref_id", :force => true do |t|
  t.integer  "app_id",                                                   :null => false
  t.integer  "route_id",                                                 :null => false
  t.integer  "route_order",                                              :null => false
  t.integer  "destination_id",                                           :null => false
  t.string   "transfer_lookup",                                          :null => false
  t.string   "dequeue_label",   :limit => 64, :default => "",            :null => false
  t.string   "dtype",           :limit => 1,  :default => "D",           :null => false
  t.string   "exit_type",                     :default => "Destination", :null => false
  t.datetime "created_at"
  t.datetime "updated_at" 
end

ActiveRecord::Migration.create_table "yacc_route", :primary_key => "route_id", :force => true do |t|
  t.integer  "app_id",                                                         :null => false
  t.string   "route_name",              :limit => 64,                          :null => false
  t.integer  "day_of_week",                                                    :null => false
  t.integer  "begin_time",                                                     :null => false
  t.integer  "end_time",                                                       :null => false
  t.string   "destid",                  :limit => 64,                          :null => false
  t.integer  "distribution_percentage",                                        :null => false
  t.datetime "created_at"
  t.datetime "updated_at" 
end

ActiveRecord::Migration.create_table "yacc_vlabel_map", :primary_key => "vlabel_map_id", :force => true do |t|
  t.integer  "app_id",                                                                :null => false
  t.string   "vlabel",                         :limit => 64,                          :null => false
  t.string   "vlabel_group",                   :limit => 64,                          :null => false
  t.string   "full_call_recording_enabled",    :limit => 1,  :default => "F",         :null => false
  t.integer  "full_call_recording_percentage",                                        :null => false
  t.string   "split_full_recording",           :limit => 1,  :default => "F",         :null => false
  t.integer  "cti_routine",                                  :default => 0
  t.integer  "preroute_group_id"
  t.integer  "survey_group_id"
  t.integer  "geo_route_group_id"
  t.string   "description"
  t.string   "multi_channel_recording",        :limit => 1,  :default => "F",         :null => false
  t.string   "mapped_dnis",                    :limit => 64
  t.datetime "created_at"
  t.datetime "updated_at" 
end

ActiveRecord::Migration.create_table "yacc_destination", :primary_key => "destination_id", :force => true do |t|
  t.integer  "app_id",                                                           :null => false
  t.string   "destination",               :limit => 64,                          :null => false
  t.string   "destination_title",         :limit => 64,                          :null => false
  t.string   "destination_property_name", :limit => 64,                          :null => false
  t.string   "destination_attr",          :limit => 1,  :default => "N",         :null => false
  t.string   "call_type",                 :limit => 64, :default => "",          :null => false
  t.datetime "created_at"
  t.datetime "updated_at" 
end

ActiveRecord::Migration.create_table "web_packages", :force => true do |t|
  t.string   "name",            :default => ""
  t.text     "description"
  t.boolean  "active",          :default => false
  t.integer  "app_id"
  t.integer  "vlabel_map_id"
  t.string   "time_zone"
end
ActiveRecord::Migration.create_table "web_profiles", :force => true do |t|
  t.integer  "package_id"
  t.string   "name",        :default => ""
  t.text     "description"
  t.boolean  "sun",         :default => false
  t.boolean  "mon",         :default => false
  t.boolean  "tue",         :default => false
  t.boolean  "wed",         :default => false
  t.boolean  "thu",         :default => false
  t.boolean  "fri",         :default => false
  t.boolean  "sat",         :default => false
  t.date     "day_of_year"
  t.integer  "app_id"
end

ActiveRecord::Migration.create_table "web_time_segments", :force => true do |t|
  t.integer  "profile_id"
  t.integer  "start_min"
  t.integer  "end_min"
  t.integer  "app_id"
end

ActiveRecord::Migration.create_table "web_routing_destinations", :force => true do |t|
  t.integer  "routing_id"
  t.integer  "call_priority"
  t.integer  "app_id"
  t.integer  "exit_id"
  t.string   "dequeue_label", :limit => 64, :default => "",            :null => false
  t.string   "exit_type",     :limit => 64, :default => "Destination"
end

ActiveRecord::Migration.create_table "web_routings", :force => true do |t|
  t.integer  "time_segment_id"
  t.integer  "percentage"
  t.string   "call_center"
  t.integer  "app_id"
end
ActiveRecord::Migration.create_table "yacc_destination", :primary_key => "destination_id", :force => true do |t|
  t.integer  "app_id",                                                           :null => false
  t.string   "destination",               :limit => 64,                          :null => false
  t.string   "destination_title",         :limit => 64,                          :null => false
  t.string   "destination_property_name", :limit => 64,                          :null => false
  t.string   "destination_attr",          :limit => 1,  :default => "N",         :null => false
  t.string   "call_type",                 :limit => 64, :default => "",          :null => false
  t.datetime "created_at"
  t.datetime "updated_at" 
end

ActiveRecord::Migration.create_table "yacc_destination_property", :primary_key => "destination_property_id", :force => true do |t|
  t.integer  "app_id",                                                                 :null => false
  t.string   "destination_property_name",       :limit => 64,                          :null => false
  t.integer  "recording_percentage",                                                   :null => false
  t.string   "transfer_pattern",                :limit => 1,                           :null => false
  t.string   "transfer_method",                 :limit => 1,                           :null => false
  t.string   "transfer_type",                   :limit => 1,                           :null => false
  t.integer  "outcome_timeout",                                                        :null => false
  t.integer  "retry_count",                                                            :null => false
  t.integer  "terminate",                                                              :null => false
  t.string   "transfer_lookup",                 :limit => 1,                           :null => false
  t.integer  "max_speed_digits",                                                       :null => false
  t.string   "music_on_hold",                   :limit => 64,                          :null => false
  t.string   "dial_or_block",                   :limit => 1,  :default => "D",         :null => false
  t.string   "pass_parentcallID",               :limit => 1,  :default => "F",         :null => false
  t.string   "cdr_auth",                        :limit => 1,  :default => "F",         :null => false
  t.integer  "outdial_format",                                :default => 0
  t.string   "agent_type",                      :limit => 1,  :default => "H",         :null => false
  t.string   "delay_recording",                 :limit => 1,  :default => "F",         :null => false
  t.string   "latched_recording",               :limit => 1,  :default => "F",         :null => false
  t.string   "hear_dtmf",                       :limit => 1,  :default => "F",         :null => false
  t.string   "commands_ok",                     :limit => 1,  :default => "T",         :null => false
  t.string   "dtmf_from_o",                     :limit => 1,  :default => "F",         :null => false
  t.string   "dtmf_to_o",                       :limit => 1,  :default => "F",         :null => false
  t.string   "dest_loc",                        :limit => 1,  :default => "V",         :null => false
  t.integer  "isup_enabled",                                  :default => 0,           :null => false
  t.string   "target_ack"
  t.string   "destination_form"
  t.string   "validation_format"
  t.boolean  "super_user_only",                               :default => false
  t.string   "dtype",                           :limit => 1,  :default => "D",         :null => false
  t.string   "pass_ids",                        :limit => 1,  :default => "F",         :null => false
  t.string   "pass_orig_dnis",                  :limit => 1,  :default => "F",         :null => false
  t.string   "pass_ced",                        :limit => 1,  :default => "F",         :null => false
  t.string   "delay_call_establish",            :limit => 1,  :default => "F",         :null => false
  t.string   "substitute_variables",            :limit => 1,  :default => "F",         :null => false
  t.string   "route_on_refer_user_id",          :limit => 1,  :default => "F",         :null => false
  t.string   "process_accumulated_xfer_digits", :limit => 1,  :default => "F",         :null => false
  t.string   "initial_page_uri_xheader",        :limit => 1,  :default => "F",         :null => false
  t.string   "block_session_progress_inbound",  :limit => 1,  :default => "F",         :null => false
  t.string   "notifications_enabled",           :limit => 1,  :default => "F",         :null => false
  t.string   "early_media",                     :limit => 1,  :default => "F",         :null => false
  t.integer  "destination_attribute_bits",                    :default => 0,           :null => false
  t.string   "queue_cti",                       :limit => 64, :default => "",          :null => false
  t.integer  "cti_routine",                                   :default => 0,           :null => false
  t.integer  "vail_command_mask0",                            :default => 2147483647,  :null => false
  t.integer  "vail_command_mask1",                            :default => 2147483647,  :null => false
  t.string   "network_type",                    :limit => 64, :default => "",          :null => false
  t.string   "ani_override",                    :limit => 64, :default => "",          :null => false
  t.boolean  "privacy",                                       :default => false,       :null => false
  t.boolean  "hidden",                                        :default => false,       :null => false
  t.datetime "created_at"
  t.datetime "updated_at" 
end

ActiveRecord::Migration.create_table "web_groups", :force => true do |t|
  t.string   "name"
  t.string   "alias"
  t.string   "category"
  t.text     "description"
  t.boolean  "group_default"
  t.datetime "created_at",                                             :null => false
  t.datetime "updated_at",                                             :null => false
  t.integer  "app_id"
  t.integer  "operation_id"
  t.string   "display_name"
  t.boolean  "show_display_name",                   :default => false
  t.integer  "position"
  t.boolean  "allow_georoute",                      :default => false
  t.integer  "original_operation"
  t.boolean  "use_mapped_dnis",                     :default => false
  t.string   "original_newop_rec",    :limit => 64
  t.string   "default_routes_filter", :limit => 1,  :default => "A"
end

ActiveRecord::Migration.create_table "yacc_op", :primary_key => "op_id", :force => true do |t|
  t.integer  "app_id",                                                        :null => false
  t.string   "vlabel_group",           :limit => 64,                          :null => false
  t.string   "description",            :limit => 64,                          :null => false
  t.integer  "operation",                                                     :null => false
  t.string   "route_name",             :limit => 64, :default => "",          :null => false
  t.string   "post_call",              :limit => 1,  :default => "F",         :null => false
  t.string   "hangup_message",         :limit => 64, :default => "",          :null => false
  t.string   "newop_rec",              :limit => 64, :default => "",          :null => false
  t.string   "default_property",       :limit => 64, :default => "",          :null => false
  t.string   "exception_route",        :limit => 1,  :default => "F",         :null => false
  t.string   "dst_name",               :limit => 64
  t.string   "cti_name",               :limit => 64
  t.string   "xfr_fail_message",       :limit => 64, :default => "",          :null => false
  t.string   "speed_ng_message",       :limit => 64, :default => "",          :null => false
  t.integer  "nvp_modified_time_unix",               :default => 0
  t.datetime "modified_time",                                                 :null => false
  t.string   "modified_by",            :limit => 64, :default => "user_name", :null => false
  t.integer  "preroute_enabled",                     :default => 0,           :null => false
  t.integer  "survey_enabled",                       :default => 0,           :null => false
  t.string   "origin_property",        :limit => 64, :default => ""
end
