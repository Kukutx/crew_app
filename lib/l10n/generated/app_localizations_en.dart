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
  String get about_update_status_up_to_date =>
      "You're on the latest version.";

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
  String get event_meeting_point_title => 'Meeting point';

  @override
  String get event_participants_title => 'Participants';

  @override
  String get event_time_title => 'Event time';

  @override
  String get event_title_field_label => 'Event Title';

  @override
  String get events_open_chat => 'Open group chat';

  @override
  String get events_tab_favorites => 'Liked';

  @override
  String get events_tab_registered => 'Joined';

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
  String get registration_not_implemented =>
      'Registration feature is not available yet.';

  @override
  String get registration_open => 'Registration open';

  @override
  String get school_label_optional => 'School (optional)';

  @override
  String get search_hint => 'Search events';

  @override
  String get search_tags_hint => 'Search tags...';

  @override
  String get settings => 'Settings';

  @override
  String get report_issue => 'Report a problem';

  @override
  String get report_issue_description =>
      'Send feedback and logs to help us fix issues faster.';

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
}
