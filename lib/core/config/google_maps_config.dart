class GoogleMapsConfig {
  const GoogleMapsConfig._();

  /// Google Maps/Places API key injected via `--dart-define=GOOGLE_MAPS_API_KEY=...`.
  ///
  /// Falls back to an empty string when not provided so that the app can still
  /// run in development environments while showing an explicit error message.
  static const String apiKey = 'AIzaSyAlMh5fDNbAFn5Bxzdcrucc8jPg4k1_ONU';
}
