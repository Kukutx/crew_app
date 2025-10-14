class RemoteConfigKeys {
  static const disclaimerJson = 'legal_disclaimer_json';
  static const appUpdateInfo = 'app_update_info';
  static const settingsDeveloperToolsEnabled =
      'settings_developer_tools_enabled';
}

class RemoteConfigDefaults {
  static const values = <String, dynamic>{
    RemoteConfigKeys.disclaimerJson: '',
    RemoteConfigKeys.appUpdateInfo: '{}',
    RemoteConfigKeys.settingsDeveloperToolsEnabled: false,
  };
}
