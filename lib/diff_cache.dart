import 'diff_cache_platform_interface.dart';

class DiffCache {
  Future<String?> getPlatformVersion() => DiffCachePlatform.instance.getPlatformVersion();

  static Future<void> init() => DiffCachePlatform.instance.init();

  Future<void> add(String name, String url) => DiffCachePlatform.instance.add(name, url);

  Future<void> update(Function(List<String> success, List<String> fail,List<String> jump) finish, {String? fileName}) async =>
      await DiffCachePlatform.instance.update(finish, fileName: fileName);

  Future<void> updateMust(Function(List<String> success, List<String> fail,List<String> jump) finish, {String? fileName}) async =>
      await DiffCachePlatform.instance.updateMust(finish, fileName: fileName);

  Future<String> read(String name) async => await DiffCachePlatform.instance.read(name);

  void remove(String name) => DiffCachePlatform.instance.remove(name);

  void clear() => DiffCachePlatform.instance.clear();
}
