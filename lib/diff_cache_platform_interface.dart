import 'package:diff_cache/cloud.dart';
import 'package:diff_cache/mmkv.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class DiffCachePlatform extends PlatformInterface {
  DiffCachePlatform() : super(token: _token);

  static final Object _token = Object();

  static DiffCachePlatform _instance = DiffCachePlatform();

  static DiffCachePlatform get instance => _instance;

  static set instance(DiffCachePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  final methodChannel = const MethodChannel('diff_cache');

  Future<String?> getPlatformVersion() async => await methodChannel.invokeMethod<String>('getPlatformVersion');

  Future<void> init() async {
    mmkv.init();
    await DC.instance.init();
  }

  Future<void> add(String name, String url) async => await DC.instance.add(name, url);

  Future<void> update(Function(List<String> success, List<String> fail,List<String> jump) finish, {String? fileName}) async =>
      await DC.instance.update(finish, fileName: fileName);

  Future<void> updateMust(Function(List<String> success, List<String> fail,List<String> jump) finish, {String? fileName}) async =>
      await DC.instance.updateMust(finish, fileName: fileName);

  Future<String> read(String name) async => await DC.instance.read(name);

  void remove(String name) => DC.instance.remove(name);

  void clear() => DC.instance.clear();
}
