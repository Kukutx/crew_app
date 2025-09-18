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
    Locale('zh')
  ];

  String get settings;
  String get dark_mode;
  String get language;
  String get about;
  String get chinese;
  String get english;
  String get about_content;
  String get action_apply;
  String get action_cancel;
  String get action_create;
  String get action_follow;
  String get action_following;
  String get action_login;
  String get action_logout;
  String get action_register;
  String get action_register_now;
  String get action_replace;
  String get action_reset;
  String get action_restore_defaults;
  String get browsing_history;
  String get city_field_label;
  String get city_loading;
  String get email_unbound;
  String get event_description_field_label;
  String get event_details_title;
  String get event_meeting_point_title;
  String get event_participants_title;
  String get event_time_title;
  String get event_title_field_label;
  String get events_tab_favorites;
  String get events_tab_registered;
  String get events_title;
  String get feature_not_ready;
  String get filter;
  String get filter_category;
  String get filter_date;
  String get filter_date_any;
  String get filter_date_this_month;
  String get filter_date_this_week;
  String get filter_date_today;
  String get filter_distance;
  String get filter_only_free;
  String get followed;
  String get favorites_empty;
  String get favorites_title;
  String get history_empty;
  String get history_title;
  String get industry_label_optional;
  String get interest_tags_title;
  String get load_failed;
  String location_coordinates(Object lat, Object lng);
  String get location_unavailable;
  String get login_footer;
  String get login_prompt;
  String get login_side_info;
  String get login_subtitle;
  String get login_title;
  String get logout_success;
  String get max_interest_selection;
  String get my_events;
  String get my_favorites;
  String get no_events;
  String get no_events_found;
  String get not_logged_in;
  String get preferences_title;
  String get please_enter_city;
  String get please_enter_event_title;
  String get profile_title;
  String get registration_not_implemented;
  String get registration_open;
  String get school_label_optional;
  String get search_hint;
  String get search_tags_hint;
  String get student_verification;
  String get tag_city_explore;
  String get tag_easy_social;
  String get tag_free;
  String get tag_friends;
  String get tag_music;
  String get tag_nearby;
  String get tag_party;
  String get tag_sports;
  String get tag_today;
  String get tag_trending;
  String get tag_walk_friendly;
  String get to_be_announced;
  String get unknown;
  String get unfollowed;
  String get user_display_name_fallback;
  String get verification_preferences;
  String version_label(Object version);
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
      'that was used.');
}
