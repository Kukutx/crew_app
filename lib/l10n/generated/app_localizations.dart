import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_content.
  ///
  /// In en, this message translates to:
  /// **'This is a universal settings page example.'**
  String get about_content;

  /// No description provided for @about_section_version_details.
  ///
  /// In en, this message translates to:
  /// **'Version information'**
  String get about_section_version_details;

  /// No description provided for @about_current_version.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get about_current_version;

  /// No description provided for @about_build_number.
  ///
  /// In en, this message translates to:
  /// **'Build number'**
  String get about_build_number;

  /// No description provided for @about_latest_version.
  ///
  /// In en, this message translates to:
  /// **'Latest version'**
  String get about_latest_version;

  /// No description provided for @about_check_updates.
  ///
  /// In en, this message translates to:
  /// **'Check latest version'**
  String get about_check_updates;

  /// No description provided for @about_update_status_up_to_date.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the latest version.'**
  String get about_update_status_up_to_date;

  /// No description provided for @about_update_status_optional.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available.'**
  String about_update_status_optional(Object version);

  /// No description provided for @about_update_status_required.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is required to continue.'**
  String about_update_status_required(Object version);

  /// No description provided for @about_update_status_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine the latest version right now.'**
  String get about_update_status_unknown;

  /// No description provided for @action_apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get action_apply;

  /// No description provided for @action_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get action_cancel;

  /// No description provided for @action_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get action_create;

  /// No description provided for @action_follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get action_follow;

  /// No description provided for @action_following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get action_following;

  /// No description provided for @action_login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get action_login;

  /// No description provided for @action_logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get action_logout;

  /// No description provided for @action_register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get action_register;

  /// No description provided for @action_register_now.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get action_register_now;

  /// No description provided for @action_replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get action_replace;

  /// No description provided for @action_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get action_reset;

  /// No description provided for @action_restore_defaults.
  ///
  /// In en, this message translates to:
  /// **'Restore default'**
  String get action_restore_defaults;

  /// No description provided for @action_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get action_retry;

  /// No description provided for @browsing_history.
  ///
  /// In en, this message translates to:
  /// **'Browsing history'**
  String get browsing_history;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @city_field_label.
  ///
  /// In en, this message translates to:
  /// **'City / Place (editable)'**
  String get city_field_label;

  /// No description provided for @city_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get city_loading;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @email_unbound.
  ///
  /// In en, this message translates to:
  /// **'Email not linked'**
  String get email_unbound;

  /// No description provided for @user_display_name_fallback.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user_display_name_fallback;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @event_description_field_label.
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get event_description_field_label;

  /// No description provided for @event_details_title.
  ///
  /// In en, this message translates to:
  /// **'Event details'**
  String get event_details_title;

  /// No description provided for @event_meeting_point_title.
  ///
  /// In en, this message translates to:
  /// **'Meeting point'**
  String get event_meeting_point_title;

  /// No description provided for @event_participants_title.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get event_participants_title;

  /// No description provided for @event_time_title.
  ///
  /// In en, this message translates to:
  /// **'Event time'**
  String get event_time_title;

  /// No description provided for @event_title_field_label.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get event_title_field_label;

  /// No description provided for @events_open_chat.
  ///
  /// In en, this message translates to:
  /// **'Open messages'**
  String get events_open_chat;

  /// No description provided for @events_tab_favorites.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get events_tab_favorites;

  /// No description provided for @events_tab_registered.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get events_tab_registered;

  /// No description provided for @events_tab_invites.
  ///
  /// In en, this message translates to:
  /// **'Invites'**
  String get events_tab_invites;

  /// No description provided for @events_tab_plaza.
  ///
  /// In en, this message translates to:
  /// **'Plaza'**
  String get events_tab_plaza;

  /// No description provided for @events_title.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events_title;

  /// No description provided for @create_event_title.
  ///
  /// In en, this message translates to:
  /// **'Create Event'**
  String get create_event_title;

  /// No description provided for @feature_not_ready.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development.'**
  String get feature_not_ready;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filter_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filter_category;

  /// No description provided for @filter_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get filter_date;

  /// No description provided for @filter_date_any.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get filter_date_any;

  /// No description provided for @filter_date_this_month.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get filter_date_this_month;

  /// No description provided for @filter_date_this_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get filter_date_this_week;

  /// No description provided for @filter_date_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filter_date_today;

  /// No description provided for @filter_distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get filter_distance;

  /// No description provided for @filter_only_free.
  ///
  /// In en, this message translates to:
  /// **'Only show free events'**
  String get filter_only_free;

  /// No description provided for @followed.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get followed;

  /// No description provided for @favorites_empty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet~'**
  String get favorites_empty;

  /// No description provided for @favorites_title.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites_title;

  /// No description provided for @history_empty.
  ///
  /// In en, this message translates to:
  /// **'No history yet~'**
  String get history_empty;

  /// No description provided for @history_title.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history_title;

  /// No description provided for @industry_label_optional.
  ///
  /// In en, this message translates to:
  /// **'Industry (optional)'**
  String get industry_label_optional;

  /// No description provided for @interest_tags_title.
  ///
  /// In en, this message translates to:
  /// **'Interest tags'**
  String get interest_tags_title;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get load_failed;

  /// No description provided for @location_coordinates.
  ///
  /// In en, this message translates to:
  /// **'Location: {lat}, {lng}'**
  String location_coordinates(Object lat, Object lng);

  /// No description provided for @location_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location'**
  String get location_unavailable;

  /// No description provided for @login_footer.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy.'**
  String get login_footer;

  /// No description provided for @login_prompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the button above to sign in and explore more features.'**
  String get login_prompt;

  /// No description provided for @login_side_info.
  ///
  /// In en, this message translates to:
  /// **'Discover nearby events · Host quickly · Subscribe for advanced features'**
  String get login_side_info;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize events by location and join your crew with one tap.'**
  String get login_subtitle;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Crew'**
  String get login_title;

  /// No description provided for @logout_success.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully.'**
  String get logout_success;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get group;

  /// No description provided for @max_interest_selection.
  ///
  /// In en, this message translates to:
  /// **'You can select up to 5 interest tags.'**
  String get max_interest_selection;

  /// No description provided for @my_events.
  ///
  /// In en, this message translates to:
  /// **'My events'**
  String get my_events;

  /// No description provided for @my_favorites.
  ///
  /// In en, this message translates to:
  /// **'My favorites'**
  String get my_favorites;

  /// No description provided for @chat_members_count.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String chat_members_count(Object count);

  /// No description provided for @chat_you_label.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chat_you_label;

  /// No description provided for @chat_message_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get chat_message_input_hint;

  /// No description provided for @chat_reply_count.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String chat_reply_count(Object count);

  /// No description provided for @no_events.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get no_events;

  /// No description provided for @no_events_found.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get no_events_found;

  /// No description provided for @not_logged_in.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get not_logged_in;

  /// No description provided for @preferences_title.
  ///
  /// In en, this message translates to:
  /// **'Profile info'**
  String get preferences_title;

  /// No description provided for @please_enter_city.
  ///
  /// In en, this message translates to:
  /// **'Please enter a city.'**
  String get please_enter_city;

  /// No description provided for @please_enter_event_title.
  ///
  /// In en, this message translates to:
  /// **'Please enter an event title.'**
  String get please_enter_event_title;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_roles_label.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get profile_roles_label;

  /// No description provided for @profile_subscription_status_active.
  ///
  /// In en, this message translates to:
  /// **'Subscription active'**
  String get profile_subscription_status_active;

  /// No description provided for @profile_subscription_status_inactive.
  ///
  /// In en, this message translates to:
  /// **'No active subscription'**
  String get profile_subscription_status_inactive;

  /// No description provided for @profile_sync_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to sync profile details'**
  String get profile_sync_error;

  /// No description provided for @registration_not_implemented.
  ///
  /// In en, this message translates to:
  /// **'Registration feature is not available yet.'**
  String get registration_not_implemented;

  /// No description provided for @registration_open.
  ///
  /// In en, this message translates to:
  /// **'Registration open'**
  String get registration_open;

  /// No description provided for @share_card_title.
  ///
  /// In en, this message translates to:
  /// **'Invite friends'**
  String get share_card_title;

  /// No description provided for @share_card_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share this event card with your friends.'**
  String get share_card_subtitle;

  /// No description provided for @share_card_qr_caption.
  ///
  /// In en, this message translates to:
  /// **'Scan to view the event details'**
  String get share_card_qr_caption;

  /// No description provided for @share_action_copy_link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get share_action_copy_link;

  /// No description provided for @share_action_save_image.
  ///
  /// In en, this message translates to:
  /// **'Save Event'**
  String get share_action_save_image;

  /// No description provided for @share_action_share_system.
  ///
  /// In en, this message translates to:
  /// **'Share…'**
  String get share_action_share_system;

  /// No description provided for @share_copy_success.
  ///
  /// In en, this message translates to:
  /// **'Event link copied'**
  String get share_copy_success;

  /// No description provided for @share_save_success.
  ///
  /// In en, this message translates to:
  /// **'Share card saved to Photos'**
  String get share_save_success;

  /// No description provided for @share_save_failure.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save share card'**
  String get share_save_failure;

  /// No description provided for @school_label_optional.
  ///
  /// In en, this message translates to:
  /// **'School (optional)'**
  String get school_label_optional;

  /// No description provided for @search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search events'**
  String get search_hint;

  /// No description provided for @search_tags_hint.
  ///
  /// In en, this message translates to:
  /// **'Search tags...'**
  String get search_tags_hint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settings_section_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settings_section_general;

  /// No description provided for @settings_section_support.
  ///
  /// In en, this message translates to:
  /// **'About & support'**
  String get settings_section_support;

  /// No description provided for @settings_section_subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription & billing'**
  String get settings_section_subscription;

  /// No description provided for @settings_section_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & safety'**
  String get settings_section_privacy;

  /// No description provided for @settings_section_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_section_account;

  /// No description provided for @settings_section_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_section_notifications;

  /// No description provided for @settings_section_developer.
  ///
  /// In en, this message translates to:
  /// **'Developer tools'**
  String get settings_section_developer;

  /// No description provided for @settings_help_feedback.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get settings_help_feedback;

  /// No description provided for @settings_help_feedback_subtitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ, contact support'**
  String get settings_help_feedback_subtitle;

  /// No description provided for @settings_app_version.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settings_app_version;

  /// No description provided for @settings_app_version_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View release notes and build info'**
  String get settings_app_version_subtitle;

  /// No description provided for @settings_subscription_current_plan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get settings_subscription_current_plan;

  /// No description provided for @settings_subscription_current_plan_value.
  ///
  /// In en, this message translates to:
  /// **'{plan} plan'**
  String settings_subscription_current_plan_value(Object plan);

  /// No description provided for @settings_subscription_plan_free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get settings_subscription_plan_free;

  /// No description provided for @settings_subscription_plan_plus.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get settings_subscription_plan_plus;

  /// No description provided for @settings_subscription_plan_pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get settings_subscription_plan_pro;

  /// No description provided for @settings_subscription_upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade subscription'**
  String get settings_subscription_upgrade;

  /// No description provided for @settings_subscription_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get settings_subscription_cancel;

  /// No description provided for @settings_subscription_payment_methods.
  ///
  /// In en, this message translates to:
  /// **'Manage payment methods'**
  String get settings_subscription_payment_methods;

  /// No description provided for @settings_location_permission.
  ///
  /// In en, this message translates to:
  /// **'Location permission'**
  String get settings_location_permission;

  /// No description provided for @settings_location_permission_allow.
  ///
  /// In en, this message translates to:
  /// **'Allow location access'**
  String get settings_location_permission_allow;

  /// No description provided for @settings_location_permission_while_using.
  ///
  /// In en, this message translates to:
  /// **'Allow only while using the app'**
  String get settings_location_permission_while_using;

  /// No description provided for @settings_location_permission_deny.
  ///
  /// In en, this message translates to:
  /// **'Deny location access'**
  String get settings_location_permission_deny;

  /// No description provided for @settings_manage_blocklist.
  ///
  /// In en, this message translates to:
  /// **'Blocked & muted users'**
  String get settings_manage_blocklist;

  /// No description provided for @settings_privacy_documents.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy & user agreement'**
  String get settings_privacy_documents;

  /// No description provided for @settings_account_info.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get settings_account_info;

  /// No description provided for @settings_account_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get settings_account_email_label;

  /// No description provided for @settings_account_uid_label.
  ///
  /// In en, this message translates to:
  /// **'UID'**
  String get settings_account_uid_label;

  /// No description provided for @settings_account_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settings_account_delete;

  /// No description provided for @settings_notifications_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity reminders'**
  String get settings_notifications_activity;

  /// No description provided for @settings_notifications_following.
  ///
  /// In en, this message translates to:
  /// **'Followed users updates'**
  String get settings_notifications_following;

  /// No description provided for @settings_notifications_push.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settings_notifications_push;

  /// No description provided for @settings_notifications_push_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable push notifications on this device'**
  String get settings_notifications_push_subtitle;

  /// No description provided for @settings_saved_toast.
  ///
  /// In en, this message translates to:
  /// **'Settings updated'**
  String get settings_saved_toast;

  /// No description provided for @report_issue.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get report_issue;

  /// No description provided for @report_issue_description.
  ///
  /// In en, this message translates to:
  /// **'Send feedback and logs to help us fix issues faster.'**
  String get report_issue_description;

  /// No description provided for @feedback_thanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get feedback_thanks;

  /// No description provided for @student_verification.
  ///
  /// In en, this message translates to:
  /// **'Student verification'**
  String get student_verification;

  /// No description provided for @tag_city_explore.
  ///
  /// In en, this message translates to:
  /// **'City exploration'**
  String get tag_city_explore;

  /// No description provided for @tag_easy_social.
  ///
  /// In en, this message translates to:
  /// **'Casual social'**
  String get tag_easy_social;

  /// No description provided for @tag_free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get tag_free;

  /// No description provided for @tag_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends joined'**
  String get tag_friends;

  /// No description provided for @tag_music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get tag_music;

  /// No description provided for @tag_nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get tag_nearby;

  /// No description provided for @tag_party.
  ///
  /// In en, this message translates to:
  /// **'Party'**
  String get tag_party;

  /// No description provided for @tag_sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get tag_sports;

  /// No description provided for @tag_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tag_today;

  /// No description provided for @tag_trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get tag_trending;

  /// No description provided for @tag_walk_friendly.
  ///
  /// In en, this message translates to:
  /// **'Walk friendly'**
  String get tag_walk_friendly;

  /// No description provided for @to_be_announced.
  ///
  /// In en, this message translates to:
  /// **'TBD'**
  String get to_be_announced;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unfollowed.
  ///
  /// In en, this message translates to:
  /// **'Unfollowed'**
  String get unfollowed;

  /// No description provided for @verification_preferences.
  ///
  /// In en, this message translates to:
  /// **'Verification & preferences'**
  String get verification_preferences;

  /// No description provided for @version_label.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version_label(Object version);

  /// No description provided for @disclaimer_acknowledge.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the terms above.'**
  String get disclaimer_acknowledge;

  /// No description provided for @disclaimer_exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get disclaimer_exit;

  /// No description provided for @disclaimer_accept.
  ///
  /// In en, this message translates to:
  /// **'Agree'**
  String get disclaimer_accept;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
