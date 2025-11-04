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
  String get about_current_version => 'Current version';

  @override
  String get about_build_number => 'Build number';

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
  String get action_cancel => 'Cancel';

  @override
  String get action_create => 'Create';

  @override
  String get action_follow => 'Follow';

  @override
  String get action_following => 'Following';

  @override
  String get action_logout => 'Log out';

  @override
  String get action_register => 'Register';

  @override
  String get action_register_now => 'Register Now';

  @override
  String get chinese => 'Chinese';

  @override
  String get city_field_label => 'City / Place (editable)';

  @override
  String get city_loading => 'Loading…';

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
  String get event_meeting_point_view_button => 'View on map';

  @override
  String get event_meeting_point_hint =>
      'Tap to view directions to the meeting point.';

  @override
  String get event_copy_address_button => 'Copy address';

  @override
  String get event_copy_address_success => 'Address copied to clipboard';

  @override
  String get event_participants_title => 'Participants';

  @override
  String get event_route_start_label => 'Start point';

  @override
  String get event_route_end_label => 'End point';

  @override
  String get event_time_title => 'Event time';

  @override
  String get event_start_time_label => 'Start time';

  @override
  String get event_end_time_label => 'End time';

  @override
  String get event_fee_title => 'Registration fee';

  @override
  String get event_fee_free => 'Free';

  @override
  String get event_expense_calculate_button => 'Calculate';

  @override
  String get event_group_expense_title => 'Group ledger';

  @override
  String get event_waypoints_title => 'Waypoints';

  @override
  String get event_route_type_title => 'Route type';

  @override
  String get event_route_type_round => 'Round trip';

  @override
  String get event_route_type_one_way => 'One-way';

  @override
  String get event_status_reviewing => 'Under review';

  @override
  String get event_status_recruiting => 'Recruiting';

  @override
  String get event_status_ongoing => 'Ongoing';

  @override
  String get event_status_ended => 'Ended';

  @override
  String get event_title_field_label => 'Event Title';

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
  String get create_moment_type_section_title => 'Moment type';

  @override
  String get create_moment_type_instant => 'Instant moment';

  @override
  String get create_moment_type_event => 'Activity moment';

  @override
  String get create_moment_event_link_label => 'Linked activity';

  @override
  String get create_moment_event_link_value => 'Road trip · Happening now';

  @override
  String get create_moment_submit_button => 'Post';

  @override
  String create_moment_preview_message(Object featureName) {
    return '$featureName is coming soon';
  }

  @override
  String get create_event_title => 'Create Event';

  @override
  String get feature_not_ready => 'This feature is under development.';

  @override
  String get filter => 'Filter';

  @override
  String get followed => 'Followed';

  @override
  String get favorites_empty => 'No favorites yet~';

  @override
  String get language => 'Language';

  @override
  String get load_failed => 'Failed to load';

  @override
  String location_coordinates(Object lat, Object lng) {
    return 'Location: $lat, $lng';
  }

  @override
  String get login_footer =>
      'By continuing, you agree to our Terms of Service and Privacy Policy.';

  @override
  String get login_prompt =>
      'Tap the button above to sign in and explore more features.';

  @override
  String get login_subtitle =>
      'Organize events by location and join your crew with one tap.';

  @override
  String get login_title => 'Welcome to Crew';

  @override
  String get login_agreement_prefix => 'I have read and agree to';

  @override
  String get login_agreement_terms => 'Terms of Service';

  @override
  String get login_agreement_privacy => 'Privacy Policy';

  @override
  String get login_agreement_children => 'Children\'s Privacy Guidelines';

  @override
  String get logout_success => 'Signed out successfully.';

  @override
  String get map => 'Map';

  @override
  String get map_clear_selected_point => 'Clear selected point';

  @override
  String get map_clear_waypoint => 'Clear waypoint';

  @override
  String get map_add_waypoint_tip =>
      'Tap the map to add a waypoint, long press to adjust start and destination';

  @override
  String get map_select_location_destination_tip =>
      'Tap the map to choose a destination.';

  @override
  String get map_guide_step_1 =>
      'Step 1: Long press on the map to choose a start location';

  @override
  String get map_guide_step_2 =>
      'Step 2: Long press on the map to choose a destination';

  @override
  String get map_guide_step_3 =>
      'Step 3: Tap the map to add waypoints (optional)';

  @override
  String get map_guide_waypoint_step_3 =>
      'Step 3: Tap the \"Add waypoint\" button, then tap the map to add a waypoint (optional)';

  @override
  String get map_guide_waypoint_manage =>
      'Drag to reorder waypoints in the list, swipe left to delete';

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
  String get map_select_location_title => 'Choose a start location';

  @override
  String get map_select_location_tip =>
      'Long press on the map to fine-tune the position.';

  @override
  String get messages => 'Messages';

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
  String get chat_attachment_image => 'Photos';

  @override
  String get chat_attachment_live_location => 'Share live location';

  @override
  String get chat_composer_emoji_tooltip => 'Emojis';

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
  String get preferences_title => 'Profile info';

  @override
  String get preferences_basic_info_title => 'Basics';

  @override
  String get preferences_display_name_label => 'Display name';

  @override
  String get preferences_display_name_placeholder => 'Your Crew name';

  @override
  String get preferences_name_empty_error => 'Display name can\'t be empty';

  @override
  String get preferences_gender_label => 'Gender';

  @override
  String get preferences_gender_female => 'Female';

  @override
  String get preferences_gender_male => 'Male';

  @override
  String get preferences_gender_custom => 'Custom';

  @override
  String get preferences_gender_custom_field_label => 'Custom gender';

  @override
  String get preferences_gender_custom_field_hint => 'Enter your gender';

  @override
  String get preferences_gender_other => 'Prefer not to say';

  @override
  String get preferences_country_label => 'Country / region';

  @override
  String get preferences_country_hint => 'Show a flag next to your avatar';

  @override
  String get preferences_country_unset => 'Not specified';

  @override
  String get country_name_china => 'China';

  @override
  String get country_name_united_states => 'United States';

  @override
  String get country_name_japan => 'Japan';

  @override
  String get country_name_korea => 'South Korea';

  @override
  String get country_name_united_kingdom => 'United Kingdom';

  @override
  String get country_name_australia => 'Australia';

  @override
  String get preferences_bio_label => 'Bio';

  @override
  String get preferences_bio_hint =>
      'Share what the Crew should know about you';

  @override
  String get preferences_bio_placeholder =>
      'Tell the community what you\'re into';

  @override
  String get preferences_tags_title => 'Interests & tags';

  @override
  String get preferences_tags_empty_helper =>
      'Add a few tags so others know your vibe';

  @override
  String get preferences_add_tag_label => 'Add a tag';

  @override
  String get preferences_tag_input_hint => 'Press enter to add';

  @override
  String get preferences_tag_duplicate => 'That tag is already added';

  @override
  String preferences_tag_limit_reached(Object count) {
    return 'You can add up to $count tags';
  }

  @override
  String get preferences_recommended_tags_title => 'Popular on Crew';

  @override
  String get preferences_cover_action => 'Change cover';

  @override
  String get preferences_avatar_action => 'Update avatar';

  @override
  String get preferences_feature_unavailable => 'Image editing is coming soon';

  @override
  String get preferences_save_success => 'Profile updated';

  @override
  String get please_enter_city => 'Please enter a city.';

  @override
  String get please_enter_event_title => 'Please enter an event title.';

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
  String get search_hint => 'Search events';

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
  String get settings_section_notifications => 'Notifications';

  @override
  String get settings_section_developer => 'Developer tools';

  @override
  String get settings_help_feedback => 'Help & feedback';

  @override
  String get settings_app_version => 'About Crew';

  @override
  String get settings_subscription_current_plan => 'Current plan';

  @override
  String get settings_subscription_plan_free => 'Free';

  @override
  String get settings_subscription_plan_plus => 'Plus';

  @override
  String get settings_subscription_plan_pro => 'Pro';

  @override
  String get subscription_plan_title => 'Subscription plans';

  @override
  String get subscription_plan_subtitle =>
      'Pick the option that fits you best. You can upgrade or cancel at any time.';

  @override
  String get subscription_plan_current_label => 'Current subscription';

  @override
  String subscription_plan_current_hint(Object plan) {
    return 'You\'re on the $plan plan right now.';
  }

  @override
  String get subscription_plan_price_free => 'Free';

  @override
  String get subscription_plan_price_plus => '¥28 / month';

  @override
  String get subscription_plan_price_pro => '¥68 / month';

  @override
  String get subscription_plan_button_selected => 'Current plan';

  @override
  String subscription_plan_button_upgrade(Object plan) {
    return 'Upgrade to $plan';
  }

  @override
  String subscription_plan_button_switch(Object plan) {
    return 'Switch to $plan';
  }

  @override
  String get subscription_plan_button_cancel => 'Cancel subscription';

  @override
  String get subscription_plan_cancel_description =>
      'Downgrade to the Free plan and keep essential features.';

  @override
  String get subscription_plan_badge_popular => 'Popular choice';

  @override
  String get subscription_plan_free_feature_discover =>
      'Discover nearby activities and hosts';

  @override
  String get subscription_plan_free_feature_save =>
      'Save your favourite experiences';

  @override
  String get subscription_plan_free_feature_notifications =>
      'Receive essential notifications';

  @override
  String get subscription_plan_plus_feature_filters =>
      'Advanced filters and smarter recommendations';

  @override
  String get subscription_plan_plus_feature_private =>
      'Create additional private events';

  @override
  String get subscription_plan_plus_feature_support =>
      'Priority member support';

  @override
  String get subscription_plan_pro_feature_collaboration =>
      'Team collaboration dashboard';

  @override
  String get subscription_plan_pro_feature_insights =>
      'Detailed performance insights';

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
  String get blocklist_title => 'Blocked users';

  @override
  String get blocklist_empty => 'You haven\'t blocked anyone yet.';

  @override
  String get blocklist_unblock => 'Unblock';

  @override
  String get blocklist_unblock_confirm_title => 'Unblock user?';

  @override
  String blocklist_unblock_confirm_message(Object name) {
    return 'Remove $name from your block list?';
  }

  @override
  String blocklist_unblocked_snackbar(Object name) {
    return 'Unblocked $name';
  }

  @override
  String get settings_privacy_documents => 'Privacy policy & user agreement';

  @override
  String get privacy_documents_page_title => 'Privacy policy & user agreement';

  @override
  String get privacy_documents_intro =>
      'We value your trust. This page summarizes how we handle your data and the rules that keep Crew safe for everyone.';

  @override
  String get privacy_documents_privacy_title => 'Privacy policy';

  @override
  String get privacy_documents_privacy_body =>
      'We collect information you share when creating and managing your account, including your name, contact details, and profile content. We also process usage data, device signals, and location information to power discovery, safety, and personalization features.\n\nWe use this data to deliver the service, communicate important updates, and improve the Crew experience. We never sell your personal information. Access is restricted to authorized team members and vetted partners who follow strict confidentiality obligations.\n\nYou may review, update, or request deletion of your personal data at any time from Settings > Account or by contacting us directly.';

  @override
  String get privacy_documents_user_agreement_title => 'User agreement';

  @override
  String get privacy_documents_user_agreement_body =>
      'By using Crew you agree to: (1) provide accurate information and keep your account secure, (2) respect other members by following our community guidelines and applicable laws, (3) use event tools responsibly without spam, harassment, or unauthorized commercial activity, and (4) acknowledge that we may suspend or terminate access when policies are violated.\n\nSome features rely on device permissions (such as location). You can manage these settings on your device, but certain functionality may be limited when permissions are disabled.';

  @override
  String get privacy_documents_contact_title => 'Contact us';

  @override
  String get privacy_documents_contact_body =>
      'Questions about privacy or the agreement? Reach our support team at support@crewapp.com and we will respond as quickly as possible.';

  @override
  String get settings_account_info => 'Account details';

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
  String get support_feedback_title => 'Feedback';

  @override
  String get support_feedback_description_label => 'Feedback description';

  @override
  String get support_feedback_description_hint =>
      'Please describe your issue or suggestion in detail.';

  @override
  String get support_feedback_media_label => 'Images & videos';

  @override
  String get support_feedback_phone_label => 'Phone number';

  @override
  String get support_feedback_phone_hint => 'Enter your mobile number';

  @override
  String get support_feedback_submit => 'Submit feedback';

  @override
  String get support_feedback_description_required =>
      'Please enter a feedback description.';

  @override
  String get support_feedback_max_attachments =>
      'You can attach up to 4 files.';

  @override
  String get support_feedback_add_photo => 'Choose photo';

  @override
  String get tag_city_explore => 'City exploration';

  @override
  String get tag_easy_social => 'Casual social';

  @override
  String get tag_walk_friendly => 'Walk friendly';

  @override
  String get to_be_announced => 'TBD';

  @override
  String get unknown => 'Unknown';

  @override
  String get unfollowed => 'Unfollowed';

  @override
  String get disclaimer_acknowledge =>
      'I have read and agree to the terms above.';

  @override
  String get disclaimer_exit => 'Exit';

  @override
  String get disclaimer_accept => 'Agree';

  @override
  String get map_quick_actions_my_moments => 'My moments';

  @override
  String get map_quick_actions_my_drafts => 'My drafts';

  @override
  String get map_quick_actions_add_friend => 'Add friends';

  @override
  String get map_quick_actions_my_event => 'My activities';

  @override
  String get map_quick_actions_my_ledger => 'My ledger';

  @override
  String get map_quick_actions_wallet => 'My wallet';

  @override
  String get map_quick_actions_bottom_scan => 'Scan';

  @override
  String get map_quick_actions_bottom_support => 'Help & support';

  @override
  String get map_quick_actions_bottom_settings => 'Settings';

  @override
  String get qr_scanner_title => 'Scan QR Code';

  @override
  String get qr_scanner_instruction =>
      'Align the QR code within the frame to scan';

  @override
  String get qr_scanner_torch_hint => 'Tap to light up';

  @override
  String get qr_scanner_my_code => 'My QR code';

  @override
  String get qr_scanner_album => 'Album';

  @override
  String get my_moments_title => 'My moments';

  @override
  String get my_drafts_title => 'My drafts';

  @override
  String get my_drafts_section_saved => 'Saved drafts';

  @override
  String get my_drafts_resume_button => 'Continue editing';

  @override
  String get map_selection_sheet_tap_to_expand => 'Tap to expand';

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

  @override
  String get wallet_title => 'Wallet';

  @override
  String get wallet_balance_label => 'Available balance';

  @override
  String wallet_last_updated(Object timeAgo) {
    return 'Updated $timeAgo ago';
  }

  @override
  String get wallet_reserved_funds => 'On hold';

  @override
  String get wallet_reward_points => 'Reward points';

  @override
  String get wallet_quick_actions => 'Quick actions';

  @override
  String get wallet_action_top_up => 'Top up';

  @override
  String get wallet_action_withdraw => 'Withdraw';

  @override
  String get wallet_action_transfer => 'Transfer';

  @override
  String get wallet_insights_title => 'Monthly insights';

  @override
  String get wallet_insights_description =>
      'Track how your balance grows across events and subscriptions.';

  @override
  String get wallet_help_description =>
      'This wallet preview shows demo data so you can explore the upcoming experience.';

  @override
  String get wallet_help_close => 'Got it';

  @override
  String get wallet_insight_income => 'Event income';

  @override
  String get wallet_insight_expense => 'Subscription costs';

  @override
  String get wallet_view_statements => 'Statements';

  @override
  String get wallet_view_statements_subtitle =>
      'Export detailed settlement history';

  @override
  String get wallet_manage_methods => 'Payment methods';

  @override
  String get wallet_manage_methods_subtitle =>
      'Manage cards and payout accounts';

  @override
  String get wallet_recent_activity => 'Recent activity';

  @override
  String get wallet_activity_empty => 'No transactions yet';

  @override
  String get wallet_transaction_payout_title => 'Event payout';

  @override
  String get wallet_transaction_payout_subtitle => 'City cycling crew · Apr 12';

  @override
  String get wallet_transaction_refund_title => 'Expense refund';

  @override
  String get wallet_transaction_refund_subtitle =>
      'Coastal camp · Trip cancelled';

  @override
  String get wallet_transaction_subscription_title => 'Crew Plus subscription';

  @override
  String get wallet_transaction_subscription_subtitle => 'Auto renewal';

  @override
  String get settings_developer_stripe_test => 'Stripe payment test';

  @override
  String get road_trip_create_button => 'Create';

  @override
  String get road_trip_continue_button => 'Continue';

  @override
  String get road_trip_image_picker_failed =>
      'Failed to pick images. Please check permission settings.';

  @override
  String get road_trip_basic_section_title => 'Basic info';

  @override
  String get road_trip_basic_section_subtitle => 'Name your trip and set dates';

  @override
  String get road_trip_basic_title_label => 'Trip title';

  @override
  String get road_trip_basic_title_hint => 'e.g., Cinque Terre coastal drive';

  @override
  String get road_trip_basic_title_required => 'Please enter a title';

  @override
  String get road_trip_basic_date_label => 'Event dates';

  @override
  String get road_trip_basic_date_hint => 'Tap to select date range';

  @override
  String get road_trip_route_section_title => 'Route type';

  @override
  String get road_trip_route_add_waypoint => 'Add waypoint';

  @override
  String get road_trip_route_add_to_forward => 'Add to outbound';

  @override
  String get road_trip_route_add_to_return => 'Add to return';

  @override
  String get road_trip_route_type_round => 'Round trip';

  @override
  String get road_trip_route_type_one_way => 'One-way';

  @override
  String road_trip_route_waypoints_one_way(int count) {
    return 'Waypoints (one-way) · $count total';
  }

  @override
  String get road_trip_route_forward_label => 'Outbound';

  @override
  String get road_trip_route_return_label => 'Return';

  @override
  String road_trip_route_waypoints_count(int count) {
    return ' · $count total';
  }

  @override
  String road_trip_route_waypoint_label(int index) {
    return 'Waypoint $index';
  }

  @override
  String get road_trip_team_section_title => 'Team settings';

  @override
  String get road_trip_team_section_subtitle => 'Participant limit & pricing';

  @override
  String get road_trip_team_pricing_free => 'Free';

  @override
  String get road_trip_team_pricing_paid => 'Paid';

  @override
  String get road_trip_team_max_participants_label => 'Max participants';

  @override
  String get road_trip_team_max_participants_hint => 'e.g., 4';

  @override
  String get road_trip_team_max_participants_error =>
      'Please enter an integer ≥ 1';

  @override
  String get road_trip_team_price_label => 'Price per person (€)';

  @override
  String get road_trip_team_price_free_hint => 'Free event';

  @override
  String get road_trip_team_price_paid_hint => 'e.g., 29.5';

  @override
  String get road_trip_preferences_section_title => 'Preferences';

  @override
  String get road_trip_preferences_car_type_label => 'Vehicle type (optional)';

  @override
  String get road_trip_preferences_car_sedan => 'Sedan';

  @override
  String get road_trip_preferences_car_suv => 'SUV';

  @override
  String get road_trip_preferences_car_hatchback => 'Hatchback';

  @override
  String get road_trip_preferences_car_van => 'Van';

  @override
  String get road_trip_preferences_tag_label => 'Add tag';

  @override
  String get road_trip_preferences_tag_hint => 'Add';

  @override
  String get road_trip_gallery_section_title => 'Gallery';

  @override
  String get road_trip_gallery_section_subtitle =>
      'Select multiple photos; first one is cover';

  @override
  String get road_trip_gallery_select_images => 'Select photos';

  @override
  String get road_trip_gallery_add_more => 'Add more';

  @override
  String get road_trip_gallery_empty_hint =>
      'No photos selected yet. Tap the button below to add.';

  @override
  String get road_trip_gallery_cover_label => 'Cover';

  @override
  String road_trip_gallery_image_label(int index) {
    return 'Photo $index';
  }

  @override
  String get road_trip_gallery_set_cover => 'Set as cover';

  @override
  String get road_trip_story_section_title => 'Highlights';

  @override
  String get road_trip_story_section_subtitle =>
      'Tell others why they should join';

  @override
  String get road_trip_story_description_label => 'Detailed description';

  @override
  String get road_trip_story_description_hint =>
      'Route highlights, notes, gear suggestions…';

  @override
  String get road_trip_story_description_required =>
      'Please enter a description';

  @override
  String get road_trip_disclaimer_section_title => 'Host disclaimer';

  @override
  String get road_trip_disclaimer_section_subtitle =>
      'Explain risks, special requirements…';

  @override
  String get road_trip_disclaimer_content_label => 'Disclaimer content';

  @override
  String get road_trip_disclaimer_content_hint =>
      'e.g., risk warnings, special notes';
}
