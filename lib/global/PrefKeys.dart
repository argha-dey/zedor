import 'package:hive/hive.dart';

class PrefKeys {
  static const String LANG = 'language';
  static const String MAMA_APP_DEVICE_TOKEN = 'zedor_app_device_token';
  static const String AUTH_TOKEN = 'zedor_auth_token';
  static const String IS_LOGIN_STATUS = 'zedor_is_login';
  static const String USER_ID = 'zedor_user_id';
  static const String USER_TYPE = 'zedor_user_type';
  static const String USER_IS_CREATE_INSTANCE = 'zedor_is_create_instance';
  static const String USER_GREEN_API_INSTANCE_ID = 'zedor_instance_id';
  static const String USER_GREEN_API_TOKEN_INSTANCE = 'zedor_instance_token';
  static const String USER_GREEN_API_TYPE_INSTANCE =
      'zedor_instance_token_type';
  static const String USER_GREEN_API_WID_ID = 'zedor_wid_id';
  static const String USER_SET_PASSCODE_VALUE = 'zedor_set_passcode_value';
  static const String USER_IS_SET_PASSCODE = 'zedor_is_set_passcode';
  static const String USER_IS_SET_PASSCODE_ENABLE_DISABLE =
      'zedor_is_set_passcode_enable_disable';
  static const String FLOATING_WIDGET_ENABLE_ENABLE_DISABLE =
      'zedor_is_widget_enable_disable';

  static const String SET_CONFIRM_PASSCODE_VIS =
      'zedor_is_set_confirm_passcode';

  static const String USER_IS_SET_FAKE_PASSCODE_ENABLE_DISABLE =
      'zedor_is_set_fake_passcode_enable_disable';

  static const String USER_SET_FAKE_PASSCODE_VALUE = 'zedor_set_fake_passcode';
  static const String SET_FAKE_PASSCODE_PAGE_VISIBLE =
      'zedor_is_fake_passcode_page_visible';

  static const String SET_USER_SCANNING_TIME = 'zedor_set_user_scanning_time';
  // static const String IS_USER_FIRST_TIME_SCANNING = 'zedor_is_user_scanning_fast_time';
}

class PrefObj {
  static Box? preferences;
}
