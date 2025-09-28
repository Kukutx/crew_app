class RemoteConfigKeys {
  static const disclaimerJson = 'legal_disclaimer_json';
  static const appUpdateInfo = 'app_update_info';
}

class RemoteConfigDefaults {
  static const values = <String, dynamic>{
    RemoteConfigKeys.disclaimerJson: '',
    RemoteConfigKeys.appUpdateInfo: '{}',
  };
}
