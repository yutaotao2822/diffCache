import 'dart:io';

import 'package:dio/dio.dart';

// void test() async {
//   DownloadApi()
//       .setUrl(FileVerify.chart)
//       .setSavePath("${(await getDownloadsDirectory())?.path}/test.json")
//       .showLoading(true)
//       .downListen((total, now) {})
//       .successListen((savePath) {})
//       .failListen((fail) {})
//       .request();
// }

class DownloadApi {
  ///网络请求框架
  final Dio _dio = Dio();

  String _url = ""; //请求地址
  String? _savePath; //下载地址
  Map<String, dynamic> _headers = {}; //请求头
  ProgressCallback? _progressEvt; //下载进度
  Function(String savePath, String content)? _successEvt; //下载完成
  Function(String fail)? _failEvt; //下载失败

  DownloadApi setSavePath(String path) {
    _savePath = path;
    return this;
  }

  DownloadApi setUrl(String url) {
    _url = url;
    return this;
  }

  DownloadApi setHeader(Map<String, dynamic> headers) {
    _headers = headers;
    return this;
  }

  DownloadApi downListen(ProgressCallback progressEvt) {
    _progressEvt = progressEvt;
    return this;
  }

  DownloadApi successListen(Function(String savePath, String content) successEvt) {
    _successEvt = successEvt;
    return this;
  }

  DownloadApi failListen(Function(String fail) failEvt) {
    _failEvt = failEvt;
    return this;
  }

  ///主动取消请求方法
  final CancelToken _cancelId = CancelToken();

  void cancel() => _cancelId.cancel();

  ///网络请求
  void request() async {
    BaseOptions opt = BaseOptions();
    opt.headers = _headers;
    _dio.options = opt;

    try {
      Response response = await _dio.download(_url, _savePath ?? "",
          cancelToken: _cancelId, onReceiveProgress: (now, total) => _progressEvt?.call(now, total));
      if (response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.created) {
        var backData = response.data;
        _successEvt?.call(_savePath ?? "", backData.toString());
      } else {
        _failEvt?.call("Fail(${response.statusCode})");
      }
    } catch (e) {
      _failEvt?.call("$e(-99)");
    }
  }
}
