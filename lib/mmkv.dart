import 'package:shared_preferences/shared_preferences.dart';

MMKV mmkv = MMKV.si;

class MMKV {
  factory MMKV() => _getInstance();

  static MMKV get si => _getInstance();
  static MMKV? _instance;

  static MMKV _getInstance() {
    _instance ??= MMKV._internal();
    return _instance!;
  }

  MMKV._internal();

  SharedPreferences? _sp;

  void init() async {
    _sp ??= await SharedPreferences.getInstance();
  }

  void setInt(String key, int value) {
    init();
    _sp?.setInt(key, value);
  }

  void setString(String key, String value) {
    init();
    _sp?.setString(key, value);
  }

  int? getInt(String key, [int? def]) {
    init();
    return _sp?.getInt(key) ?? def;
  }

  String? getString(String key, [String? def]) {
    init();
    return _sp?.getString(key) ?? def;
  }

  void remove(String key) {
    init();
    _sp?.remove(key);
  }
}
