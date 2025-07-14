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

  final dfKey = "DC_DiffCache_yt";

  ///
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
    String? key = mmkv.getString(dfKey);
    if (key == null || key.isEmpty) return [];
    List<String> keys = key.split("||");
    keys.removeLast();
    return keys;
  }

  Future<void> _dealUpdateSingle(String name,
      {required Function(List<String> success, List<String> fail, List<String> jump) finish, bool must = false}) async {
    String tag = await FileVerifyApi().verify(name.dcUrl);
    if (must || tag != name.dcTag) {
      DownloadApi()
          .setUrl(name.dcUrl ?? "")
          .setSavePath("$savePath${name.dcFile}")
          .downListen((now, total) {})
          .successListen((savePath, content) async {
        name.dcTagSet(tag);
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

    print("updList:$updList");

    updList.forEach((item) async {
      if (item.dcUrl.isNullOrEmpty) return;
      String tag = await FileVerifyApi().verify(item.dcUrl);
      if (must || tag != item.dcTag) {
        _download(
            name: item,
            url: item.dcUrl ?? "",
            filePath: "$savePath${item.dcFile}",
            success: (name) {
              name.dcTagSet(tag);
              cnt++;
              successTag.add(name);
              if (cnt == updList.length) finish.call(successTag, failTag, jumpTag);
            },
            fail: (name) {
              cnt++;
              failTag.add(name);
              if (cnt == updList.length) finish.call(successTag, failTag, jumpTag);
            });
      } else {
        cnt++;
        jumpTag.add(item);
        if (cnt == updList.length) finish.call(successTag, failTag, jumpTag);
      }
    });
  }

  void _download(
          {required String name,
          required String url,
          required String filePath,
          required Function(String name) success,
          required Function(String name) fail}) =>
      DownloadApi()
          .setUrl(url)
          .setSavePath(filePath)
          .downListen((now, total) {})
          .successListen((savePath, content) async => success.call(name))
          .failListen((f) => fail.call(name))
          .request();

  Future<String> read(String name) async => await File("$savePath${name.dcFile}").readAsString();

  //添加缓存文件
  Future<void> add(String name, String url) async {
    mmkv.setString("${name}_url", url);
    mmkv.setString("${name}_file", name);
    String pp = mmkv.getString(dfKey) ?? "";
    if (!pp.contains(name)) mmkv.setString(dfKey, "$pp$name||");
  }

  //移除缓存文件
  void remove(String name) async {
    try {
      if (!name.dcFile.isNullOrEmpty) await File("$savePath${name.dcFile}").delete();
    } catch (e) {
      print("$e");
    }
    String pp = mmkv.getString(dfKey) ?? "";
    if (pp.contains(name)) pp = pp.replaceAll("$name||", "");
    mmkv.setString(dfKey, pp);
    name.dcDel;
  }

  void clear() async {
    var list = _updateList();
    mmkv.remove(dfKey);
    for (var item in list) {
      try {
        if (!item.dcFile.isNullOrEmpty) await File("$savePath${item.dcFile}").delete();
      } catch (e) {
        print("$e");
      }
      item.dcDel;
    }
  }
}
