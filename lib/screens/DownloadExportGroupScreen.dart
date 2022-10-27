import 'package:flutter/material.dart';
import 'package:pikapika/basic/Common.dart';

import '../basic/Entities.dart';
import '../basic/Method.dart';
import 'DownloadExportingGroupScreen.dart';
import 'components/ContentLoading.dart';
import 'components/DownloadInfoCard.dart';

class DownloadExportGroupScreen extends StatefulWidget {
  const DownloadExportGroupScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DownloadExportGroupScreenState();
}

class _DownloadExportGroupScreenState extends State<DownloadExportGroupScreen> {
  late Future<List<DownloadComic>> _f = method.allDownloads("");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _f,
      builder:
          (BuildContext context, AsyncSnapshot<List<DownloadComic>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("批量导出"),
            ),
            body: const ContentLoading(label: '加载中'),
          );
        }

        if (snapshot.hasError) {
          print("${snapshot.error}");
          print("${snapshot.stackTrace}");
          return Scaffold(
            appBar: AppBar(
              title: const Text("批量导出"),
            ),
            body: const Center(child: Text('加载失败')),
          );
        }

        var data = snapshot.data!;

        List<Widget> ws = [];
        List<DownloadComic> exportable = [];
        List<String> exportableIds = [];
        for (var value in data) {
          if (!value.deleting && value.downloadFinished) {
            ws.add(downloadWidget(value));
            exportable.add(value);
            exportableIds.add(value.id);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text("批量导出"),
            actions: [
              _selectAllButton(exportableIds),
              _goToExport(),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                selected.clear();
                _f = method.allDownloads("");
              });
            },
            child: ListView(
              children: ws,
            ),
          ),
        );
      },
    );
  }

  List<String> selected = [];

  Widget downloadWidget(DownloadComic e) {
    return InkWell(
      onTap: () {
        if (selected.contains(e.id)) {
          selected.remove(e.id);
        } else {
          selected.add(e.id);
        }
        setState(() {});
      },
      child: Stack(children: [
        DownloadInfoCard(
          task: e,
        ),
        Row(children: [
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
              selected.contains(e.id)
                  ? Icons.check_circle_sharp
                  : Icons.circle_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _selectAllButton(List<String> exportableIds) {
    return MaterialButton(
        minWidth: 0,
        onPressed: () async {
          setState(() {
            if (selected.length >= exportableIds.length) {
              selected.clear();
            } else {
              selected.clear();
              selected.addAll(exportableIds);
            }
          });
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.select_all,
              size: 18,
              color: Colors.white,
            ),
            const Text(
              '全选',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ));
  }

  Widget _goToExport() {
    return MaterialButton(
        minWidth: 0,
        onPressed: () async {
          if (selected.isEmpty) {
            defaultToast(context, "请选择导出的内容");
            return;
          }
          final exported = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DownloadExportingGroupScreen(
                idList: selected,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            const Icon(
              Icons.check,
              size: 18,
              color: Colors.white,
            ),
            const Text(
              '确认',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Expanded(child: Container()),
          ],
        ));
  }
}
