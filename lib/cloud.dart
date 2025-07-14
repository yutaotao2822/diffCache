import 'dart:io';

import 'package:diff_cache/api/api_download.dart';
import 'package:diff_cache/api/api_file_verify.dart';
import 'package:diff_cache/mmkv.dart';
import 'package:diff_cache/util.dart';
import 'package:path_provider/path_provider.dart';

class DC {
  factory DC() => _getInstance();

  static DC get instance => _getInstance();
  static DC? _instance;

  static DC _getInstance() {
    _instance ??= DC._internal();
    return _instance!;
  }

  DC._internal();

  ///
  final FileVerifyApi _verApi = FileVerifyApi();
  final DownloadApi downApi = DownloadApi();
  String savePath = "";

  //初始化
  //获取所有的文件
  Future<void> init() async {
    if (savePath.isNullOrEmpty) savePath = "${(await getTemporaryDirectory()).path}/diff_cache/";
  }

  //更新所有的文件
  Future<void> update(Function(List<String> success, List<String> fail, List<String> jump) finish,
      {String? fileName}) async {
    if (fileName.isNullOrEmpty) {
      await _dealUpdate(finish: finish);
    } else {
      await _dealUpdateSingle(fileName!, finish: finish);
    }
  }

  //强制更新所有的文件
  Future<void> updateMust(Function(List<String> success, List<String> fail, List<String> jump) finish,
      {String? fileName}) async {
    if (fileName.isNullOrEmpty) {
      await _dealUpdate(finish: finish, must: true);
    } else {
      await _dealUpdateSingle(fileName!, finish: finish, must: true);
    }
  }

  List<String> _updateList() {
    String? key = mmkv.getString("DC_DiffCache_yt");
    if (key == null || key.isEmpty) return [];
    List<String> keys = key.split("||");
    keys.removeLast();
    return keys;
  }

  Future<void> _dealUpdateSingle(String name,
      {required Function(List<String> success, List<String> fail, List<String> jump) finish, bool must = false}) async {
    String tag = await _verApi.verify(name.dcUrl);
    if (must || tag != name.dcTag) {
      downApi
          .setUrl(name.dcUrl ?? "")
          .setSavePath("$savePath${name.dcFile}")
          .downListen((now, total) {})
          .successListen((savePath, content) async {
        name.dcTagSet(tag);
        print("savePath:$savePath");
        finish.call([name], [], []);
      }).failListen((fail) {
        finish.call([], [fail], []);
      }).request();
    } else {
      finish.call([], [], [name]);
    }
  }

  Future<void> _dealUpdate({
    required Function(List<String> success, List<String> fail, List<String> jump) finish,
    bool must = false,
  }) async {
    var cnt = 0;
    var updList = _updateList();
    List<String> failTag = [];
    List<String> successTag = [];
    List<String> jumpTag = [];

    for (String item in updList) {
      if (!item.dcUrl.isNullOrEmpty) {
        String tag = await _verApi.verify(item.dcUrl);
        if (must || tag != item.dcTag) {
          downApi
              .setUrl(item.dcUrl ?? "")
              .setSavePath("$savePath${item.dcFile}")
              .downListen((now, total) {})
              .successListen((savePath, content) async {
            item.dcTagSet(tag);
            cnt++;
            successTag.add(item);
            if (cnt == updList.length) finish.call(successTag, failTag, jumpTag);
          }).failListen((fail) {
            cnt++;
            failTag.add(item);
            if (cnt == updList.length) finish.call(successTag, failTag, jumpTag);
          }).request();
        } else {
          cnt++;
          jumpTag.add(item);
          if (cnt == updList.length) finish.call(successTag, failTag, jumpTag);
        }
      }
    }
  }

  Future<String> read(String name) async => await File("$savePath${name.dcFile}").readAsString();

  //添加缓存文件
  Future<void> add(String name, String url) async {
    mmkv.setString("${name}_url", url);
    mmkv.setString("${name}_file", name);
    String pp = mmkv.getString("DC_DiffCache_yt") ?? "";
    if (!pp.contains(name)) mmkv.setString("DC_DiffCache_yt", "$pp$name||");
    print(mmkv.getString("DC_DiffCache_yt"));
  }

  //移除缓存文件
  void remove(String name) async {
    await File("$savePath${name.dcFile}").delete();
    name.dcDel;
  }

  void clear() async {
    var list = _updateList();
    for (var item in list) {
      await File("$savePath${item.dcFile}").delete();
      item.dcDel;
    }
  }
}
