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

  /// No description provided for @event_detail_publish_plaza.
  ///
  /// In en, this message translates to:
  /// **'Post to Plaza'**
  String get event_detail_publish_plaza;

  /// No description provided for @event_meeting_point_title.
  ///
  /// In en, this message translates to:
  /// **'Meeting point'**
  String get event_meeting_point_title;

  /// No description provided for @event_copy_address_button.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get event_copy_address_button;

  /// No description provided for @event_copy_address_success.
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get event_copy_address_success;

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

  /// No description provided for @event_fee_title.
  ///
  /// In en, this message translates to:
  /// **'Registration fee'**
  String get event_fee_title;

  /// No description provided for @event_fee_free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get event_fee_free;

  /// No description provided for @event_cost_calculator_title.
  ///
  /// In en, this message translates to:
  /// **'Cost calculator'**
  String get event_cost_calculator_title;

  /// No description provided for @event_cost_calculator_description.
  ///
  /// In en, this message translates to:
  /// **'Estimate participant fees, carpool costs and commission splits.'**
  String get event_cost_calculator_description;

  /// No description provided for @event_cost_calculator_button.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get event_cost_calculator_button;

  /// No description provided for @event_cost_calculator_participants_label.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get event_cost_calculator_participants_label;

  /// No description provided for @event_cost_calculator_fee_label.
  ///
  /// In en, this message translates to:
  /// **'Fee per person (¥)'**
  String get event_cost_calculator_fee_label;

  /// No description provided for @event_cost_calculator_carpool_label.
  ///
  /// In en, this message translates to:
  /// **'Total carpool cost (¥)'**
  String get event_cost_calculator_carpool_label;

  /// No description provided for @event_cost_calculator_commission_label.
  ///
  /// In en, this message translates to:
  /// **'Commission rate (%)'**
  String get event_cost_calculator_commission_label;

  /// No description provided for @event_cost_calculator_total_income.
  ///
  /// In en, this message translates to:
  /// **'Total registration income'**
  String get event_cost_calculator_total_income;

  /// No description provided for @event_cost_calculator_commission_total.
  ///
  /// In en, this message translates to:
  /// **'Commission payout'**
  String get event_cost_calculator_commission_total;

  /// No description provided for @event_cost_calculator_carpool_share.
  ///
  /// In en, this message translates to:
  /// **'Carpool cost per person'**
  String get event_cost_calculator_carpool_share;

  /// No description provided for @event_cost_calculator_net_total.
  ///
  /// In en, this message translates to:
  /// **'Net income after costs'**
  String get event_cost_calculator_net_total;

  /// No description provided for @event_cost_calculator_net_per_person.
  ///
  /// In en, this message translates to:
  /// **'Net income per person'**
  String get event_cost_calculator_net_per_person;

  /// No description provided for @event_cost_calculator_hint.
  ///
  /// In en, this message translates to:
  /// **'Adjust any number to match the actual expenses for this trip.'**
  String get event_cost_calculator_hint;

  /// No description provided for @event_expense_section_title.
  ///
  /// In en, this message translates to:
  /// **'Expense calculation'**
  String get event_expense_section_title;

  /// No description provided for @event_expense_section_description.
  ///
  /// In en, this message translates to:
  /// **'Keep track of shared costs with your crew and settle up easily after the trip.'**
  String get event_expense_section_description;

  /// No description provided for @event_expense_calculate_button.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get event_expense_calculate_button;

  /// No description provided for @event_group_expense_title.
  ///
  /// In en, this message translates to:
  /// **'Group ledger'**
  String get event_group_expense_title;

  /// No description provided for @event_group_expense_intro.
  ///
  /// In en, this message translates to:
  /// **'Create and track shared expenses for everyone on this trip.'**
  String get event_group_expense_intro;

  /// No description provided for @event_group_expense_hint.
  ///
  /// In en, this message translates to:
  /// **'Add participants, log costs on the go, and we\'ll help you settle balances fairly.'**
  String get event_group_expense_hint;

  /// No description provided for @event_waypoints_title.
  ///
  /// In en, this message translates to:
  /// **'Waypoints'**
  String get event_waypoints_title;

  /// No description provided for @event_route_type_title.
  ///
  /// In en, this message translates to:
  /// **'Route type'**
  String get event_route_type_title;

  /// No description provided for @event_route_type_round.
  ///
  /// In en, this message translates to:
  /// **'Round trip'**
  String get event_route_type_round;

  /// No description provided for @event_route_type_one_way.
  ///
  /// In en, this message translates to:
  /// **'One-way'**
  String get event_route_type_one_way;

  /// No description provided for @event_distance_title.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get event_distance_title;

  /// No description provided for @event_distance_value.
  ///
  /// In en, this message translates to:
  /// **'{kilometers} km'**
  String event_distance_value(String kilometers);

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

  /// No description provided for @messages_tab_private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get messages_tab_private;

  /// No description provided for @messages_tab_groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get messages_tab_groups;

  /// No description provided for @events_tab_invites.
  ///
  /// In en, this message translates to:
  /// **'Invites'**
  String get events_tab_invites;

  /// No description provided for @events_tab_moments.
  ///
  /// In en, this message translates to:
  /// **'Moments'**
  String get events_tab_moments;

  /// No description provided for @create_moment_title.
  ///
  /// In en, this message translates to:
  /// **'Share a moment'**
  String get create_moment_title;

  /// No description provided for @create_moment_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture what you\'re experiencing right now and inspire others nearby.'**
  String get create_moment_subtitle;

  /// No description provided for @create_moment_description_label.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening?'**
  String get create_moment_description_label;

  /// No description provided for @create_moment_add_photo.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get create_moment_add_photo;

  /// No description provided for @create_moment_add_location.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get create_moment_add_location;

  /// No description provided for @create_moment_submit_button.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get create_moment_submit_button;

  /// No description provided for @create_moment_preview_message.
  ///
  /// In en, this message translates to:
  /// **'{featureName} is coming soon'**
  String create_moment_preview_message(Object featureName);

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

  /// No description provided for @map_clear_selected_point.
  ///
  /// In en, this message translates to:
  /// **'Clear selected point'**
  String get map_clear_selected_point;

  /// No description provided for @map_location_info_title.
  ///
  /// In en, this message translates to:
  /// **'Location info'**
  String get map_location_info_title;

  /// No description provided for @map_location_info_address_loading.
  ///
  /// In en, this message translates to:
  /// **'Looking up address…'**
  String get map_location_info_address_loading;

  /// No description provided for @map_location_info_address_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Address unavailable'**
  String get map_location_info_address_unavailable;

  /// No description provided for @map_location_info_create_event.
  ///
  /// In en, this message translates to:
  /// **'Create event here'**
  String get map_location_info_create_event;

  /// No description provided for @map_location_info_nearby_title.
  ///
  /// In en, this message translates to:
  /// **'Nearby places'**
  String get map_location_info_nearby_title;

  /// No description provided for @map_location_info_nearby_empty.
  ///
  /// In en, this message translates to:
  /// **'No places found within 100 m.'**
  String get map_location_info_nearby_empty;

  /// No description provided for @map_location_info_nearby_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to load nearby places.'**
  String get map_location_info_nearby_error;

  /// No description provided for @map_place_details_title.
  ///
  /// In en, this message translates to:
  /// **'Place details'**
  String get map_place_details_title;

  /// No description provided for @map_place_details_not_found.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find details for this place.'**
  String get map_place_details_not_found;

  /// No description provided for @map_place_details_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to load place details right now.'**
  String get map_place_details_error;

  /// No description provided for @map_place_details_missing_api_key.
  ///
  /// In en, this message translates to:
  /// **'Places search is unavailable: API key is not configured.'**
  String get map_place_details_missing_api_key;

  /// No description provided for @map_place_details_rating_value.
  ///
  /// In en, this message translates to:
  /// **'Rating {rating}'**
  String map_place_details_rating_value(Object rating);

  /// No description provided for @map_place_details_no_rating.
  ///
  /// In en, this message translates to:
  /// **'No rating yet'**
  String get map_place_details_no_rating;

  /// No description provided for @map_place_details_reviews.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No reviews} =1 {1 review} other {{count} reviews}}'**
  String map_place_details_reviews(int count);

  /// No description provided for @map_place_details_price_free.
  ///
  /// In en, this message translates to:
  /// **'Price level: Free'**
  String get map_place_details_price_free;

  /// No description provided for @map_place_details_price_inexpensive.
  ///
  /// In en, this message translates to:
  /// **'Price level: \$'**
  String get map_place_details_price_inexpensive;

  /// No description provided for @map_place_details_price_moderate.
  ///
  /// In en, this message translates to:
  /// **'Price level: \$\$'**
  String get map_place_details_price_moderate;

  /// No description provided for @map_place_details_price_expensive.
  ///
  /// In en, this message translates to:
  /// **'Price level: \$\$\$'**
  String get map_place_details_price_expensive;

  /// No description provided for @map_place_details_price_very_expensive.
  ///
  /// In en, this message translates to:
  /// **'Price level: \$\$\$\$'**
  String get map_place_details_price_very_expensive;

  /// No description provided for @map_place_details_price_unknown.
  ///
  /// In en, this message translates to:
  /// **'Price level: unknown'**
  String get map_place_details_price_unknown;

  /// No description provided for @map_select_location_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a start location'**
  String get map_select_location_title;

  /// No description provided for @map_select_location_tip.
  ///
  /// In en, this message translates to:
  /// **'Long press on the map to fine-tune the position.'**
  String get map_select_location_tip;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

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

  /// No description provided for @chat_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search chats'**
  String get chat_search_hint;

  /// No description provided for @chat_search_title.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get chat_search_title;

  /// No description provided for @chat_search_no_results.
  ///
  /// In en, this message translates to:
  /// **'No messages match your search.'**
  String get chat_search_no_results;

  /// No description provided for @chat_status_online.
  ///
  /// In en, this message translates to:
  /// **'Online now'**
  String get chat_status_online;

  /// No description provided for @chat_last_seen.
  ///
  /// In en, this message translates to:
  /// **'Last active {time}'**
  String chat_last_seen(Object time);

  /// No description provided for @chat_action_video_call.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get chat_action_video_call;

  /// No description provided for @chat_action_phone_call.
  ///
  /// In en, this message translates to:
  /// **'Phone call'**
  String get chat_action_phone_call;

  /// No description provided for @chat_action_more_options.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get chat_action_more_options;

  /// No description provided for @chat_action_open_settings.
  ///
  /// In en, this message translates to:
  /// **'Chat settings'**
  String get chat_action_open_settings;

  /// No description provided for @chat_action_unavailable.
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon.'**
  String chat_action_unavailable(Object feature);

  /// No description provided for @chat_attachment_more.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get chat_attachment_more;

  /// No description provided for @chat_attachment_files.
  ///
  /// In en, this message translates to:
  /// **'Quick attachment'**
  String get chat_attachment_files;

  /// No description provided for @chat_attachment_media.
  ///
  /// In en, this message translates to:
  /// **'Photos & videos'**
  String get chat_attachment_media;

  /// No description provided for @chat_attachment_live_location.
  ///
  /// In en, this message translates to:
  /// **'Share live location'**
  String get chat_attachment_live_location;

  /// No description provided for @chat_composer_emoji_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Emojis'**
  String get chat_composer_emoji_tooltip;

  /// No description provided for @chat_composer_attach_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get chat_composer_attach_tooltip;

  /// No description provided for @chat_composer_more_tooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get chat_composer_more_tooltip;

  /// No description provided for @chat_composer_send_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chat_composer_send_tooltip;

  /// No description provided for @chat_composer_voice_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get chat_composer_voice_tooltip;

  /// No description provided for @chat_voice_recording_title.
  ///
  /// In en, this message translates to:
  /// **'Recording voice message'**
  String get chat_voice_recording_title;

  /// No description provided for @chat_voice_recording_description.
  ///
  /// In en, this message translates to:
  /// **'Release to finish recording, then send or cancel your voice message.'**
  String get chat_voice_recording_description;

  /// No description provided for @chat_voice_recording_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chat_voice_recording_cancel;

  /// No description provided for @chat_voice_recording_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chat_voice_recording_send;

  /// No description provided for @chat_voice_recording_sent_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Voice message sent.'**
  String get chat_voice_recording_sent_confirmation;

  /// No description provided for @chat_voice_recording_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Recording discarded.'**
  String get chat_voice_recording_cancelled;

  /// No description provided for @chat_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Chat settings'**
  String get chat_settings_title;

  /// No description provided for @chat_settings_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get chat_settings_share;

  /// No description provided for @chat_settings_leave_group.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get chat_settings_leave_group;

  /// No description provided for @chat_settings_remove_friend.
  ///
  /// In en, this message translates to:
  /// **'Remove contact'**
  String get chat_settings_remove_friend;

  /// No description provided for @chat_settings_leave_group_confirmation_title.
  ///
  /// In en, this message translates to:
  /// **'Leave this group?'**
  String get chat_settings_leave_group_confirmation_title;

  /// No description provided for @chat_settings_leave_group_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'You will no longer receive messages from this group.'**
  String get chat_settings_leave_group_confirmation_message;

  /// No description provided for @chat_settings_remove_friend_confirmation_title.
  ///
  /// In en, this message translates to:
  /// **'Remove this contact?'**
  String get chat_settings_remove_friend_confirmation_title;

  /// No description provided for @chat_settings_remove_friend_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'This chat will be removed from your list.'**
  String get chat_settings_remove_friend_confirmation_message;

  /// No description provided for @chat_settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get chat_settings_notifications;

  /// No description provided for @chat_settings_notifications_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Mute or enable alerts'**
  String get chat_settings_notifications_subtitle;

  /// No description provided for @chat_settings_shared_files.
  ///
  /// In en, this message translates to:
  /// **'Shared photos & videos'**
  String get chat_settings_shared_files;

  /// No description provided for @chat_settings_shared_files_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse images and videos from this chat'**
  String get chat_settings_shared_files_subtitle;

  /// No description provided for @chat_settings_report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chat_settings_report;

  /// No description provided for @chat_shared_media_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chat_shared_media_filter_all;

  /// No description provided for @chat_shared_media_filter_photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get chat_shared_media_filter_photos;

  /// No description provided for @chat_shared_media_filter_videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get chat_shared_media_filter_videos;

  /// No description provided for @chat_shared_media_empty.
  ///
  /// In en, this message translates to:
  /// **'No photos or videos have been shared yet.'**
  String get chat_shared_media_empty;

  /// No description provided for @chat_shared_media_caption.
  ///
  /// In en, this message translates to:
  /// **'{sender} · {time}'**
  String chat_shared_media_caption(Object sender, Object time);

  /// No description provided for @chat_settings_members_section.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get chat_settings_members_section;

  /// No description provided for @chat_settings_contact_section.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get chat_settings_contact_section;

  /// No description provided for @chat_settings_contact_id.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String chat_settings_contact_id(Object id);

  /// No description provided for @chat_settings_group_overview.
  ///
  /// In en, this message translates to:
  /// **'Group · {memberLabel}'**
  String chat_settings_group_overview(Object memberLabel);

  /// No description provided for @chat_settings_direct_overview.
  ///
  /// In en, this message translates to:
  /// **'Direct chat'**
  String get chat_settings_direct_overview;

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

  /// No description provided for @preferences_basic_info_title.
  ///
  /// In en, this message translates to:
  /// **'Basics'**
  String get preferences_basic_info_title;

  /// No description provided for @preferences_display_name_label.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get preferences_display_name_label;

  /// No description provided for @preferences_display_name_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Your Crew name'**
  String get preferences_display_name_placeholder;

  /// No description provided for @preferences_name_empty_error.
  ///
  /// In en, this message translates to:
  /// **'Display name can't be empty'**
  String get preferences_name_empty_error;

  /// No description provided for @preferences_bio_label.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get preferences_bio_label;

  /// No description provided for @preferences_bio_hint.
  ///
  /// In en, this message translates to:
  /// **'Share what the Crew should know about you'**
  String get preferences_bio_hint;

  /// No description provided for @preferences_bio_placeholder.
  ///
  /// In en, this message translates to:
  /// **"Tell the community what you're into"**
  String get preferences_bio_placeholder;

  /// No description provided for @preferences_tags_title.
  ///
  /// In en, this message translates to:
  /// **'Interests & tags'**
  String get preferences_tags_title;

  /// No description provided for @preferences_tags_empty_helper.
  ///
  /// In en, this message translates to:
  /// **'Add a few tags so others know your vibe'**
  String get preferences_tags_empty_helper;

  /// No description provided for @preferences_add_tag_label.
  ///
  /// In en, this message translates to:
  /// **'Add a tag'**
  String get preferences_add_tag_label;

  /// No description provided for @preferences_tag_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Press enter to add'**
  String get preferences_tag_input_hint;

  /// No description provided for @preferences_tag_duplicate.
  ///
  /// In en, this message translates to:
  /// **'That tag is already added'**
  String get preferences_tag_duplicate;

  /// No description provided for @preferences_tag_limit_reached.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {count} tags'**
  String preferences_tag_limit_reached(int count);

  /// No description provided for @preferences_recommended_tags_title.
  ///
  /// In en, this message translates to:
  /// **'Popular on Crew'**
  String get preferences_recommended_tags_title;

  /// No description provided for @preferences_cover_action.
  ///
  /// In en, this message translates to:
  /// **'Change cover'**
  String get preferences_cover_action;

  /// No description provided for @preferences_avatar_action.
  ///
  /// In en, this message translates to:
  /// **'Update avatar'**
  String get preferences_avatar_action;

  /// No description provided for @preferences_feature_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Image editing is coming soon'**
  String get preferences_feature_unavailable;

  /// No description provided for @preferences_save_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get preferences_save_success;

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
  /// **'Report'**
  String get report_issue;

  /// No description provided for @report_issue_description.
  ///
  /// In en, this message translates to:
  /// **'Help us review by selecting a reason and sharing details.'**
  String get report_issue_description;

  /// No description provided for @report_event_type_label.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get report_event_type_label;

  /// No description provided for @report_event_type_required.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason.'**
  String get report_event_type_required;

  /// No description provided for @report_event_type_misinformation.
  ///
  /// In en, this message translates to:
  /// **'Incorrect or misleading information'**
  String get report_event_type_misinformation;

  /// No description provided for @report_event_type_illegal.
  ///
  /// In en, this message translates to:
  /// **'Illegal or prohibited content'**
  String get report_event_type_illegal;

  /// No description provided for @report_event_type_fraud.
  ///
  /// In en, this message translates to:
  /// **'Suspected fraud or scam'**
  String get report_event_type_fraud;

  /// No description provided for @report_event_type_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get report_event_type_other;

  /// No description provided for @report_event_content_label.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get report_event_content_label;

  /// No description provided for @report_event_content_hint.
  ///
  /// In en, this message translates to:
  /// **'Provide more information so our team can review this.'**
  String get report_event_content_hint;

  /// No description provided for @report_event_content_required.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue.'**
  String get report_event_content_required;

  /// No description provided for @report_event_attachment_label.
  ///
  /// In en, this message translates to:
  /// **'Photo evidence'**
  String get report_event_attachment_label;

  /// No description provided for @report_event_attachment_optional.
  ///
  /// In en, this message translates to:
  /// **'Optional but helps us review faster.'**
  String get report_event_attachment_optional;

  /// No description provided for @report_event_attachment_add.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get report_event_attachment_add;

  /// No description provided for @report_event_attachment_replace.
  ///
  /// In en, this message translates to:
  /// **'Replace photo'**
  String get report_event_attachment_replace;

  /// No description provided for @report_event_attachment_empty.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get report_event_attachment_empty;

  /// No description provided for @report_event_attachment_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load that photo. Please try again.'**
  String get report_event_attachment_error;

  /// No description provided for @report_event_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get report_event_submit;

  /// No description provided for @report_event_submit_success.
  ///
  /// In en, this message translates to:
  /// **'Thank you! We\'ll review this event shortly.'**
  String get report_event_submit_success;

  /// No description provided for @report_direct_submit_success.
  ///
  /// In en, this message translates to:
  /// **'Thank you! We\'ll review this conversation shortly.'**
  String get report_direct_submit_success;

  /// No description provided for @report_group_submit_success.
  ///
  /// In en, this message translates to:
  /// **'Thank you! We\'ll review this group shortly.'**
  String get report_group_submit_success;

  /// No description provided for @report_user_type_harassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get report_user_type_harassment;

  /// No description provided for @report_user_type_impersonation.
  ///
  /// In en, this message translates to:
  /// **'Impersonation or fake identity'**
  String get report_user_type_impersonation;

  /// No description provided for @report_user_type_inappropriate.
  ///
  /// In en, this message translates to:
  /// **'Sharing inappropriate content'**
  String get report_user_type_inappropriate;

  /// No description provided for @report_user_type_spam.
  ///
  /// In en, this message translates to:
  /// **'Spam or advertising'**
  String get report_user_type_spam;

  /// No description provided for @report_user_type_other.
  ///
  /// In en, this message translates to:
  /// **'Other issues'**
  String get report_user_type_other;

  /// No description provided for @report_group_type_illegal.
  ///
  /// In en, this message translates to:
  /// **'Illegal or prohibited group content'**
  String get report_group_type_illegal;

  /// No description provided for @report_group_type_hate.
  ///
  /// In en, this message translates to:
  /// **'Hate speech or abusive behaviour'**
  String get report_group_type_hate;

  /// No description provided for @report_group_type_spam.
  ///
  /// In en, this message translates to:
  /// **'Spam or unwanted promotion'**
  String get report_group_type_spam;

  /// No description provided for @report_group_type_fraud.
  ///
  /// In en, this message translates to:
  /// **'Fraud or scam activity'**
  String get report_group_type_fraud;

  /// No description provided for @report_group_type_other.
  ///
  /// In en, this message translates to:
  /// **'Other group issues'**
  String get report_group_type_other;

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

  /// No description provided for @map_quick_trip_default_title.
  ///
  /// In en, this message translates to:
  /// **'Road trip'**
  String get map_quick_trip_default_title;

  /// No description provided for @map_quick_trip_description.
  ///
  /// In en, this message translates to:
  /// **'From {start} to {destination}.'**
  String map_quick_trip_description(Object start, Object destination);

  /// No description provided for @map_quick_trip_created.
  ///
  /// In en, this message translates to:
  /// **'Quick trip created.'**
  String get map_quick_trip_created;

  /// No description provided for @map_quick_trip_create_failed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t create this trip.'**
  String get map_quick_trip_create_failed;

  /// No description provided for @map_quick_actions_title.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get map_quick_actions_title;

  /// No description provided for @map_quick_actions_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick what you\'d like to do next.'**
  String get map_quick_actions_subtitle;

  /// No description provided for @map_quick_actions_quick_trip.
  ///
  /// In en, this message translates to:
  /// **'Quick trip'**
  String get map_quick_actions_quick_trip;

  /// No description provided for @map_quick_actions_quick_trip_desc.
  ///
  /// In en, this message translates to:
  /// **'Choose start and destination directly on the map.'**
  String get map_quick_actions_quick_trip_desc;

  /// No description provided for @map_quick_actions_full_trip.
  ///
  /// In en, this message translates to:
  /// **'Full road trip'**
  String get map_quick_actions_full_trip;

  /// No description provided for @map_quick_actions_full_trip_desc.
  ///
  /// In en, this message translates to:
  /// **'Open the complete form to plan a detailed journey.'**
  String get map_quick_actions_full_trip_desc;

  /// No description provided for @map_quick_actions_create_moment.
  ///
  /// In en, this message translates to:
  /// **'Share a moment'**
  String get map_quick_actions_create_moment;

  /// No description provided for @map_quick_actions_create_moment_desc.
  ///
  /// In en, this message translates to:
  /// **'Post photos or updates to the community.'**
  String get map_quick_actions_create_moment_desc;

  /// No description provided for @map_quick_trip_select_start_tip.
  ///
  /// In en, this message translates to:
  /// **'Long press on the map to pick a starting point.'**
  String get map_quick_trip_select_start_tip;

  /// No description provided for @map_selection_sheet_tap_to_expand.
  ///
  /// In en, this message translates to:
  /// **'Tap to expand'**
  String get map_selection_sheet_tap_to_expand;

  /// No description provided for @map_select_location_destination_tip.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to choose a destination.'**
  String get map_select_location_destination_tip;

  /// No description provided for @map_select_location_destination_missing.
  ///
  /// In en, this message translates to:
  /// **'Pick a destination to continue.'**
  String get map_select_location_destination_missing;

  /// No description provided for @map_select_location_trip_title_label.
  ///
  /// In en, this message translates to:
  /// **'Trip title'**
  String get map_select_location_trip_title_label;

  /// No description provided for @map_select_location_trip_title_hint.
  ///
  /// In en, this message translates to:
  /// **'Give this trip a name'**
  String get map_select_location_trip_title_hint;

  /// No description provided for @map_select_location_title_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter a trip title.'**
  String get map_select_location_title_required;

  /// No description provided for @map_select_location_start_label.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get map_select_location_start_label;

  /// No description provided for @map_select_location_destination_label.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get map_select_location_destination_label;

  /// No description provided for @map_select_location_open_detailed.
  ///
  /// In en, this message translates to:
  /// **'Open detailed planner'**
  String get map_select_location_open_detailed;

  /// No description provided for @map_select_location_create_trip.
  ///
  /// In en, this message translates to:
  /// **'Create quick trip'**
  String get map_select_location_create_trip;

  /// No description provided for @wallet_title.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet_title;

  /// No description provided for @wallet_overview_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View balance, rewards and statements'**
  String get wallet_overview_subtitle;

  /// No description provided for @wallet_balance_label.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get wallet_balance_label;

  /// No description provided for @wallet_last_updated.
  ///
  /// In en, this message translates to:
  /// **'Updated {timeAgo} ago'**
  String wallet_last_updated(Object timeAgo);

  /// No description provided for @wallet_reserved_funds.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get wallet_reserved_funds;

  /// No description provided for @wallet_reward_points.
  ///
  /// In en, this message translates to:
  /// **'Reward points'**
  String get wallet_reward_points;

  /// No description provided for @wallet_quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get wallet_quick_actions;

  /// No description provided for @wallet_action_top_up.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get wallet_action_top_up;

  /// No description provided for @wallet_action_withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get wallet_action_withdraw;

  /// No description provided for @wallet_action_transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get wallet_action_transfer;

  /// No description provided for @wallet_insights_title.
  ///
  /// In en, this message translates to:
  /// **'Monthly insights'**
  String get wallet_insights_title;

  /// No description provided for @wallet_insights_description.
  ///
  /// In en, this message translates to:
  /// **'Track how your balance grows across events and subscriptions.'**
  String get wallet_insights_description;

  /// No description provided for @wallet_help_description.
  ///
  /// In en, this message translates to:
  /// **'This wallet preview shows demo data so you can explore the upcoming experience.'**
  String get wallet_help_description;

  /// No description provided for @wallet_help_close.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get wallet_help_close;

  /// No description provided for @wallet_insight_income.
  ///
  /// In en, this message translates to:
  /// **'Event income'**
  String get wallet_insight_income;

  /// No description provided for @wallet_insight_expense.
  ///
  /// In en, this message translates to:
  /// **'Subscription costs'**
  String get wallet_insight_expense;

  /// No description provided for @wallet_view_statements.
  ///
  /// In en, this message translates to:
  /// **'Statements'**
  String get wallet_view_statements;

  /// No description provided for @wallet_view_statements_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Export detailed settlement history'**
  String get wallet_view_statements_subtitle;

  /// No description provided for @wallet_manage_methods.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get wallet_manage_methods;

  /// No description provided for @wallet_manage_methods_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage cards and payout accounts'**
  String get wallet_manage_methods_subtitle;

  /// No description provided for @wallet_recent_activity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get wallet_recent_activity;

  /// No description provided for @wallet_activity_empty.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get wallet_activity_empty;

  /// No description provided for @wallet_transaction_payout_title.
  ///
  /// In en, this message translates to:
  /// **'Event payout'**
  String get wallet_transaction_payout_title;

  /// No description provided for @wallet_transaction_payout_subtitle.
  ///
  /// In en, this message translates to:
  /// **'City cycling crew · Apr 12'**
  String get wallet_transaction_payout_subtitle;

  /// No description provided for @wallet_transaction_refund_title.
  ///
  /// In en, this message translates to:
  /// **'Expense refund'**
  String get wallet_transaction_refund_title;

  /// No description provided for @wallet_transaction_refund_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Coastal camp · Trip cancelled'**
  String get wallet_transaction_refund_subtitle;

  /// No description provided for @wallet_transaction_subscription_title.
  ///
  /// In en, this message translates to:
  /// **'Crew Plus subscription'**
  String get wallet_transaction_subscription_title;

  /// No description provided for @wallet_transaction_subscription_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto renewal'**
  String get wallet_transaction_subscription_subtitle;
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
