import 'package:diff_cache/cloud.dart';
import 'package:diff_cache/diff_cache.dart';
import 'package:diff_cache/mmkv.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DiffCache.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: const Text('Plugin example app')),
          body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(onPressed: tapAdd, child: const Text("Add")),
                ElevatedButton(onPressed: tapDictionary, child: const Text("Dictionary")),
                ElevatedButton(onPressed: tapDictionaryMust, child: const Text("Dictionary Must")),
                ElevatedButton(onPressed: tapChart, child: const Text("Chart")),
                ElevatedButton(onPressed: tapChartMust, child: const Text("Chart Must")),
                ElevatedButton(onPressed: tapEvt, child: const Text("Update")),
                ElevatedButton(onPressed: tapMustEvt, child: const Text("UpdateMust")),
                ElevatedButton(onPressed: tapReadDictionary, child: const Text("Read Dictionary")),
                ElevatedButton(onPressed: tapReadChart, child: const Text("Read Chart")),
                ElevatedButton(onPressed: tapDelDictionary, child: const Text("Delete Dictionary")),
                ElevatedButton(onPressed: tapDelChart, child: const Text("Delete Chart")),
                ElevatedButton(onPressed: taoClear, child: const Text("Clear")),
              ])));

  String dictionaryUrl = "http://1.95.128.88/app/config/app_dictionary.json";
  String chartUrl = "http://1.95.128.88/app/config/app_chart.json";

  final DiffCache dc = DiffCache();

  void tapAdd() async {
    await dc.add("dc_dictionary", dictionaryUrl);
    await dc.add("dc_chart", chartUrl);
  }

  void tapDictionary() async => await dc.update(_log, fileName: "dc_dictionary");

  void tapDictionaryMust() async => await dc.updateMust(_log, fileName: "dc_dictionary");

  void tapChart() async => await dc.update(_log, fileName: "dc_chart");

  void tapChartMust() async => await dc.updateMust(_log, fileName: "dc_chart");

  void tapEvt() async => await dc.update(_log);

  void tapMustEvt() async => await dc.updateMust(_log);

  void tapReadDictionary() async => print(await dc.read("dc_dictionary"));

  void tapReadChart() async => print(await dc.read("dc_chart"));

  void _log(List<String> success, List<String> fail, List<String> jump) => print(
      "——————————————————\n更新成功:${success.toString()}\n更新失败：${fail.toString()}\n跳过更新：${jump.toString()}\n——————————————————");

  void tapDelDictionary() => dc.remove("dc_dictionary");

  void tapDelChart() => dc.remove("dc_chart");

  void taoClear() => dc.clear();
}
