import 'dart:core';
import 'package:diff_cache/mmkv.dart';

extension DCBeanStringExtension on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  void get dcDel => _remove();

  String? get dcTag => mmkv.getString("${this}_tag");

  String? get dcUrl => mmkv.getString("${this}_url");

  String? get dcFile => mmkv.getString("${this}_file");

  void dcTagSet(String tag) => mmkv.setString("${this}_tag", tag);

  void _remove() {
    if (isNullOrEmpty) return;
    mmkv.remove("${this}_tag");
    mmkv.remove("${this}_url");
    mmkv.remove("${this}_file");
  }
}
