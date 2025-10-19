// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get about_content => 'This is a universal settings page example.';

  @override
  String get about_section_version_details => 'Version information';

  @override
  String get about_current_version => 'Current version';

  @override
  String get about_build_number => 'Build number';

  @override
  String get about_latest_version => 'Latest version';

  @override
  String get about_check_updates => 'Check latest version';

  @override
  String get about_update_status_up_to_date => 'You\'re on the latest version.';

  @override
  String about_update_status_optional(Object version) {
    return 'Version $version is available.';
  }

  @override
  String about_update_status_required(Object version) {
    return 'Version $version is required to continue.';
  }

  @override
  String get about_update_status_unknown =>
      'Unable to determine the latest version right now.';

  @override
  String get action_apply => 'Apply';

  @override
  String get action_cancel => 'Cancel';

  @override
  String get action_create => 'Create';

  @override
  String get action_follow => 'Follow';

  @override
  String get action_following => 'Following';

  @override
  String get action_login => 'Log in';

  @override
  String get action_logout => 'Log out';

  @override
  String get action_register => 'Register';

  @override
  String get action_register_now => 'Register Now';

  @override
  String get action_replace => 'Replace';

  @override
  String get action_reset => 'Reset';

  @override
  String get action_restore_defaults => 'Restore default';

  @override
  String get action_retry => 'Retry';

  @override
  String get browsing_history => 'Browsing history';

  @override
  String get chinese => 'Chinese';

  @override
  String get city_field_label => 'City / Place (editable)';

  @override
  String get city_loading => 'Loading…';

  @override
  String get dark_mode => 'Dark Mode';

  @override
  String get email_unbound => 'Email not linked';

  @override
  String get user_display_name_fallback => 'User';

  @override
  String get english => 'English';

  @override
  String get events => 'Events';

  @override
  String get event_description_field_label => 'Event Description';

  @override
  String get event_details_title => 'Event details';

  @override
  String get event_detail_publish_plaza => 'Post to Plaza';

  @override
  String get event_meeting_point_title => 'Meeting point';

  @override
  String get event_copy_address_button => 'Copy address';

  @override
  String get event_copy_address_success => 'Address copied to clipboard';

  @override
  String get event_participants_title => 'Participants';

  @override
  String get event_time_title => 'Event time';

  @override
  String get event_fee_title => 'Registration fee';

  @override
  String get event_fee_free => 'Free';

  @override
  String get event_cost_calculator_title => 'Cost calculator';

  @override
  String get event_cost_calculator_description =>
      'Estimate participant fees, carpool costs and commission splits.';

  @override
  String get event_cost_calculator_button => 'Calculator';

  @override
  String get event_cost_calculator_participants_label => 'Participants';

  @override
  String get event_cost_calculator_fee_label => 'Fee per person (¥)';

  @override
  String get event_cost_calculator_carpool_label => 'Total carpool cost (¥)';

  @override
  String get event_cost_calculator_commission_label => 'Commission rate (%)';

  @override
  String get event_cost_calculator_total_income => 'Total registration income';

  @override
  String get event_cost_calculator_commission_total => 'Commission payout';

  @override
  String get event_cost_calculator_carpool_share => 'Carpool cost per person';

  @override
  String get event_cost_calculator_net_total => 'Net income after costs';

  @override
  String get event_cost_calculator_net_per_person => 'Net income per person';

  @override
  String get event_cost_calculator_hint =>
      'Adjust any number to match the actual expenses for this trip.';

  @override
  String get event_expense_section_title => 'Expense calculation';

  @override
  String get event_expense_section_description =>
      'Keep track of shared costs with your crew and settle up easily after the trip.';

  @override
  String get event_expense_calculate_button => 'Calculate';

  @override
  String get event_group_expense_title => 'Group ledger';

  @override
  String get event_group_expense_intro =>
      'Create and track shared expenses for everyone on this trip.';

  @override
  String get event_group_expense_hint =>
      'Add participants, log costs on the go, and we\'ll help you settle balances fairly.';

  @override
  String get event_waypoints_title => 'Waypoints';

  @override
  String get event_route_type_title => 'Route type';

  @override
  String get event_route_type_round => 'Round trip';

  @override
  String get event_route_type_one_way => 'One-way';

  @override
  String get event_distance_title => 'Distance';

  @override
  String event_distance_value(String kilometers) {
    return '$kilometers km';
  }

  @override
  String get event_title_field_label => 'Event Title';

  @override
  String get events_open_chat => 'Open messages';

  @override
  String get messages_tab_private => 'Private';

  @override
  String get messages_tab_groups => 'Groups';

  @override
  String get events_tab_invites => 'Invites';

  @override
  String get events_tab_moments => 'Moments';

  @override
  String get create_moment_title => 'Share a moment';

  @override
  String get create_moment_subtitle =>
      'Capture what you\'re experiencing right now and inspire others nearby.';

  @override
  String get create_moment_description_label => 'What\'s happening?';

  @override
  String get create_moment_add_photo => 'Add photo';

  @override
  String get create_moment_add_location => 'Add location';

  @override
  String get create_moment_submit_button => 'Post';

  @override
  String create_moment_preview_message(Object featureName) {
    return '$featureName is coming soon';
  }

  @override
  String get events_title => 'Events';

  @override
  String get create_event_title => 'Create Event';

  @override
  String get feature_not_ready => 'This feature is under development.';

  @override
  String get filter => 'Filter';

  @override
  String get filter_category => 'Category';

  @override
  String get filter_date => 'Date';

  @override
  String get filter_date_any => 'Any time';

  @override
  String get filter_date_this_month => 'This month';

  @override
  String get filter_date_this_week => 'This week';

  @override
  String get filter_date_today => 'Today';

  @override
  String get filter_distance => 'Distance';

  @override
  String get filter_only_free => 'Only show free events';

  @override
  String get followed => 'Followed';

  @override
  String get favorites_empty => 'No favorites yet~';

  @override
  String get favorites_title => 'Favorites';

  @override
  String get history_empty => 'No history yet~';

  @override
  String get history_title => 'History';

  @override
  String get industry_label_optional => 'Industry (optional)';

  @override
  String get interest_tags_title => 'Interest tags';

  @override
  String get language => 'Language';

  @override
  String get load_failed => 'Failed to load';

  @override
  String location_coordinates(Object lat, Object lng) {
    return 'Location: $lat, $lng';
  }

  @override
  String get location_unavailable => 'Unable to get location';

  @override
  String get login_footer =>
      'By continuing, you agree to our Terms of Service and Privacy Policy.';

  @override
  String get login_prompt =>
      'Tap the button above to sign in and explore more features.';

  @override
  String get login_side_info =>
      'Discover nearby events · Host quickly · Subscribe for advanced features';

  @override
  String get login_subtitle =>
      'Organize events by location and join your crew with one tap.';

  @override
  String get login_title => 'Welcome to Crew';

  @override
  String get logout_success => 'Signed out successfully.';

  @override
  String get map => 'Map';

  @override
  String get map_clear_selected_point => 'Clear selected point';

  @override
  String get map_location_info_title => 'Location info';

  @override
  String get map_location_info_address_loading => 'Looking up address…';

  @override
  String get map_location_info_address_unavailable => 'Address unavailable';

  @override
  String get map_location_info_create_event => 'Create event here';

  @override
  String get map_location_info_nearby_title => 'Nearby places';

  @override
  String get map_location_info_nearby_empty => 'No places found within 100 m.';

  @override
  String get map_location_info_nearby_error => 'Unable to load nearby places.';

  @override
  String get map_place_details_title => 'Place details';

  @override
  String get map_place_details_not_found =>
      'We couldn\'t find details for this place.';

  @override
  String get map_place_details_error =>
      'Unable to load place details right now.';

  @override
  String get map_place_details_missing_api_key =>
      'Places search is unavailable: API key is not configured.';

  @override
  String map_place_details_rating_value(Object rating) {
    return 'Rating $rating';
  }

  @override
  String get map_place_details_no_rating => 'No rating yet';

  @override
  String map_place_details_reviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String get map_place_details_price_free => 'Price level: Free';

  @override
  String get map_place_details_price_inexpensive => 'Price level: \$';

  @override
  String get map_place_details_price_moderate => 'Price level: \$\$';

  @override
  String get map_place_details_price_expensive => 'Price level: \$\$\$';

  @override
  String get map_place_details_price_very_expensive => 'Price level: \$\$\$\$';

  @override
  String get map_place_details_price_unknown => 'Price level: unknown';

  @override
  String get map_select_location_title => 'Choose a start location';

  @override
  String get map_select_location_tip =>
      'Long press on the map to fine-tune the position.';

  @override
  String get messages => 'Messages';

  @override
  String get max_interest_selection => 'You can select up to 5 interest tags.';

  @override
  String get my_events => 'My events';

  @override
  String get my_favorites => 'My favorites';

  @override
  String chat_members_count(Object count) {
    return '$count members';
  }

  @override
  String get chat_you_label => 'You';

  @override
  String get chat_message_input_hint => 'Type a message';

  @override
  String chat_reply_count(Object count) {
    return '$count replies';
  }

  @override
  String get chat_search_hint => 'Search chats';

  @override
  String get chat_search_title => 'Search messages';

  @override
  String get chat_search_no_results => 'No messages match your search.';

  @override
  String get chat_status_online => 'Online now';

  @override
  String chat_last_seen(Object time) {
    return 'Last active $time';
  }

  @override
  String get chat_action_video_call => 'Video call';

  @override
  String get chat_action_phone_call => 'Phone call';

  @override
  String get chat_action_more_options => 'More actions';

  @override
  String get chat_action_open_settings => 'Chat settings';

  @override
  String chat_action_unavailable(Object feature) {
    return '$feature is coming soon.';
  }

  @override
  String get chat_attachment_more => 'More actions';

  @override
  String get chat_attachment_files => 'Quick attachment';

  @override
  String get chat_attachment_media => 'Photos & videos';

  @override
  String get chat_attachment_live_location => 'Share live location';

  @override
  String get chat_composer_emoji_tooltip => 'Emojis';

  @override
  String get chat_composer_attach_tooltip => 'Files';

  @override
  String get chat_composer_more_tooltip => 'More';

  @override
  String get chat_composer_send_tooltip => 'Send message';

  @override
  String get chat_composer_voice_tooltip => 'Voice message';

  @override
  String get chat_voice_recording_title => 'Recording voice message';

  @override
  String get chat_voice_recording_description =>
      'Release to finish recording, then send or cancel your voice message.';

  @override
  String get chat_voice_recording_cancel => 'Cancel';

  @override
  String get chat_voice_recording_send => 'Send';

  @override
  String get chat_voice_recording_sent_confirmation => 'Voice message sent.';

  @override
  String get chat_voice_recording_cancelled => 'Recording discarded.';

  @override
  String get chat_settings_title => 'Chat settings';

  @override
  String get chat_settings_share => 'Share';

  @override
  String get chat_settings_leave_group => 'Leave group';

  @override
  String get chat_settings_remove_friend => 'Remove contact';

  @override
  String get chat_settings_leave_group_confirmation_title =>
      'Leave this group?';

  @override
  String get chat_settings_leave_group_confirmation_message =>
      'You will no longer receive messages from this group.';

  @override
  String get chat_settings_remove_friend_confirmation_title =>
      'Remove this contact?';

  @override
  String get chat_settings_remove_friend_confirmation_message =>
      'This chat will be removed from your list.';

  @override
  String get chat_settings_notifications => 'Notifications';

  @override
  String get chat_settings_notifications_subtitle => 'Mute or enable alerts';

  @override
  String get chat_settings_shared_files => 'Shared photos & videos';

  @override
  String get chat_settings_shared_files_subtitle =>
      'Browse images and videos from this chat';

  @override
  String get chat_settings_report => 'Report';

  @override
  String get chat_shared_media_filter_all => 'All';

  @override
  String get chat_shared_media_filter_photos => 'Photos';

  @override
  String get chat_shared_media_filter_videos => 'Videos';

  @override
  String get chat_shared_media_empty =>
      'No photos or videos have been shared yet.';

  @override
  String chat_shared_media_caption(Object sender, Object time) {
    return '$sender · $time';
  }

  @override
  String get chat_settings_members_section => 'Members';

  @override
  String get chat_settings_contact_section => 'Contact info';

  @override
  String chat_settings_contact_id(Object id) {
    return 'ID: $id';
  }

  @override
  String chat_settings_group_overview(Object memberLabel) {
    return 'Group · $memberLabel';
  }

  @override
  String get chat_settings_direct_overview => 'Direct chat';

  @override
  String get no_events => 'No events yet';

  @override
  String get no_events_found => 'No events found';

  @override
  String get not_logged_in => 'Not logged in';

  @override
  String get preferences_title => 'Profile info';

  @override
  String get please_enter_city => 'Please enter a city.';

  @override
  String get please_enter_event_title => 'Please enter an event title.';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_roles_label => 'Roles';

  @override
  String get profile_subscription_status_active => 'Subscription active';

  @override
  String get profile_subscription_status_inactive => 'No active subscription';

  @override
  String get profile_sync_error => 'Unable to sync profile details';

  @override
  String get registration_not_implemented =>
      'Registration feature is not available yet.';

  @override
  String get registration_open => 'Registration open';

  @override
  String get share_card_title => 'Invite friends';

  @override
  String get share_card_subtitle => 'Share this event card with your friends.';

  @override
  String get share_card_qr_caption => 'Scan to view the event details';

  @override
  String get share_action_copy_link => 'Copy link';

  @override
  String get share_action_save_image => 'Save Event';

  @override
  String get share_action_share_system => 'Share…';

  @override
  String get share_copy_success => 'Event link copied';

  @override
  String get share_save_success => 'Share card saved to Photos';

  @override
  String get share_save_failure => 'Couldn\'t save share card';

  @override
  String get school_label_optional => 'School (optional)';

  @override
  String get search_hint => 'Search events';

  @override
  String get search_tags_hint => 'Search tags...';

  @override
  String get settings => 'Settings';

  @override
  String get settings_section_general => 'General';

  @override
  String get settings_section_support => 'About & support';

  @override
  String get settings_section_subscription => 'Subscription & billing';

  @override
  String get settings_section_privacy => 'Privacy & safety';

  @override
  String get settings_section_account => 'Account';

  @override
  String get settings_section_notifications => 'Notifications';

  @override
  String get settings_section_developer => 'Developer tools';

  @override
  String get settings_help_feedback => 'Help & feedback';

  @override
  String get settings_help_feedback_subtitle => 'FAQ, contact support';

  @override
  String get settings_app_version => 'App version';

  @override
  String get settings_app_version_subtitle =>
      'View release notes and build info';

  @override
  String get settings_subscription_current_plan => 'Current plan';

  @override
  String settings_subscription_current_plan_value(Object plan) {
    return '$plan plan';
  }

  @override
  String get settings_subscription_plan_free => 'Free';

  @override
  String get settings_subscription_plan_plus => 'Plus';

  @override
  String get settings_subscription_plan_pro => 'Pro';

  @override
  String get settings_subscription_upgrade => 'Upgrade subscription';

  @override
  String get settings_subscription_cancel => 'Cancel subscription';

  @override
  String get settings_subscription_payment_methods => 'Manage payment methods';

  @override
  String get settings_location_permission => 'Location permission';

  @override
  String get settings_location_permission_allow => 'Allow location access';

  @override
  String get settings_location_permission_while_using =>
      'Allow only while using the app';

  @override
  String get settings_location_permission_deny => 'Deny location access';

  @override
  String get settings_manage_blocklist => 'Blocked & muted users';

  @override
  String get settings_privacy_documents => 'Privacy policy & user agreement';

  @override
  String get settings_account_info => 'Account details';

  @override
  String get settings_account_email_label => 'Email';

  @override
  String get settings_account_uid_label => 'UID';

  @override
  String get settings_account_delete => 'Delete account';

  @override
  String get settings_notifications_activity => 'Activity reminders';

  @override
  String get settings_notifications_following => 'Followed users updates';

  @override
  String get settings_notifications_push => 'Push notifications';

  @override
  String get settings_notifications_push_subtitle =>
      'Enable push notifications on this device';

  @override
  String get settings_saved_toast => 'Settings updated';

  @override
  String get report_issue => 'Report';

  @override
  String get report_issue_description =>
      'Help us review by selecting a reason and sharing details.';

  @override
  String get report_event_type_label => 'Reason';

  @override
  String get report_event_type_required => 'Please select a reason.';

  @override
  String get report_event_type_misinformation =>
      'Incorrect or misleading information';

  @override
  String get report_event_type_illegal => 'Illegal or prohibited content';

  @override
  String get report_event_type_fraud => 'Suspected fraud or scam';

  @override
  String get report_event_type_other => 'Other';

  @override
  String get report_event_content_label => 'Details';

  @override
  String get report_event_content_hint =>
      'Provide more information so our team can review this.';

  @override
  String get report_event_content_required => 'Please describe the issue.';

  @override
  String get report_event_attachment_label => 'Photo evidence';

  @override
  String get report_event_attachment_optional =>
      'Optional but helps us review faster.';

  @override
  String get report_event_attachment_add => 'Add photo';

  @override
  String get report_event_attachment_replace => 'Replace photo';

  @override
  String get report_event_attachment_empty => 'No file selected';

  @override
  String get report_event_attachment_error =>
      'We couldn\'t load that photo. Please try again.';

  @override
  String get report_event_submit => 'Submit report';

  @override
  String get report_event_submit_success =>
      'Thank you! We\'ll review this event shortly.';

  @override
  String get report_direct_submit_success =>
      'Thank you! We\'ll review this conversation shortly.';

  @override
  String get report_group_submit_success =>
      'Thank you! We\'ll review this group shortly.';

  @override
  String get report_user_type_harassment => 'Harassment or bullying';

  @override
  String get report_user_type_impersonation => 'Impersonation or fake identity';

  @override
  String get report_user_type_inappropriate => 'Sharing inappropriate content';

  @override
  String get report_user_type_spam => 'Spam or advertising';

  @override
  String get report_user_type_other => 'Other issues';

  @override
  String get report_group_type_illegal => 'Illegal or prohibited group content';

  @override
  String get report_group_type_hate => 'Hate speech or abusive behaviour';

  @override
  String get report_group_type_spam => 'Spam or unwanted promotion';

  @override
  String get report_group_type_fraud => 'Fraud or scam activity';

  @override
  String get report_group_type_other => 'Other group issues';

  @override
  String get feedback_thanks => 'Thanks for your feedback!';

  @override
  String get student_verification => 'Student verification';

  @override
  String get tag_city_explore => 'City exploration';

  @override
  String get tag_easy_social => 'Casual social';

  @override
  String get tag_free => 'Free';

  @override
  String get tag_friends => 'Friends joined';

  @override
  String get tag_music => 'Music';

  @override
  String get tag_nearby => 'Nearby';

  @override
  String get tag_party => 'Party';

  @override
  String get tag_sports => 'Sports';

  @override
  String get tag_today => 'Today';

  @override
  String get tag_trending => 'Trending';

  @override
  String get tag_walk_friendly => 'Walk friendly';

  @override
  String get to_be_announced => 'TBD';

  @override
  String get unknown => 'Unknown';

  @override
  String get unfollowed => 'Unfollowed';

  @override
  String get verification_preferences => 'Verification & preferences';

  @override
  String version_label(Object version) {
    return 'Version $version';
  }

  @override
  String get disclaimer_acknowledge =>
      'I have read and agree to the terms above.';

  @override
  String get disclaimer_exit => 'Exit';

  @override
  String get disclaimer_accept => 'Agree';

  @override
  String get map_quick_trip_default_title => 'Road trip';

  @override
  String map_quick_trip_description(Object start, Object destination) {
    return 'From $start to $destination.';
  }

  @override
  String get map_quick_trip_created => 'Quick trip created.';

  @override
  String get map_quick_trip_create_failed => 'We couldn\'t create this trip.';

  @override
  String get map_selection_sheet_tap_to_expand => 'Tap to expand';

  @override
  String get map_select_location_destination_tip =>
      'Tap the map to choose a destination.';

  @override
  String get map_select_location_destination_missing =>
      'Pick a destination to continue.';

  @override
  String get map_select_location_trip_title_label => 'Trip title';

  @override
  String get map_select_location_trip_title_hint => 'Give this trip a name';

  @override
  String get map_select_location_title_required => 'Please enter a trip title.';

  @override
  String get map_select_location_start_label => 'Start';

  @override
  String get map_select_location_destination_label => 'Destination';

  @override
  String get map_select_location_open_detailed => 'Open detailed planner';

  @override
  String get map_select_location_create_trip => 'Create quick trip';
}
