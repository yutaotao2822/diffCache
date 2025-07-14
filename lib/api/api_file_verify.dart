import 'package:diff_cache/util.dart';
import 'package:dio/dio.dart';

class FileVerify {
  static const dictionary = "http://1.95.128.88/app/config/app_dictionary.json";
  static const chart = "http://1.95.128.88/app/config/app_chart.json";
}

class FileVerifyApi {
  Future<String> verify(String? url) async {
    if (url.isNullOrEmpty) return "";
    var dio = Dio();
    var response = await dio.head(url!);
    return response.headers.value('etag').toString();
  }
}
