import 'package:flutter_test/flutter_test.dart';
import 'package:diff_cache/diff_cache.dart';
import 'package:diff_cache/diff_cache_platform_interface.dart';

void main() {
  final DiffCachePlatform initialPlatform = DiffCachePlatform.instance;

  test('$DiffCachePlatform is the default instance', () {
    expect(initialPlatform, isInstanceOf<DiffCachePlatform>());
  });

  test('getPlatformVersion', () async {
    DiffCache diffCachePlugin = DiffCache();
    DiffCachePlatform fakePlatform = DiffCachePlatform();
    DiffCachePlatform.instance = fakePlatform;

    expect(await diffCachePlugin.getPlatformVersion(), '42');
  });
}
