import 'dart:io';
import 'dart:ui';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/IoslateMethods.dart';
import 'package:bytes_cloud/utils/SPWrapper.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SearchFilePage extends StatefulWidget {
  final Map<String, dynamic> args;
  SearchFilePage(this.args);
  @override
  State<StatefulWidget> createState() => new _SearchFilePageState(this.args);
}

class _SearchFilePageState extends State<SearchFilePage> {
  List<String> roots;
  String key;
  static const PAGE_LENGTH = 100;
  List<String> historyKeys = [];
  final controller = TextEditingController();
  Set<String> selectedFiles = Set();
  int filesSize = 0;
  Map<String, dynamic> args;

  bool flashListView = false;
  bool isDeepSearch = false;
  Widget list;
  List<FileSystemEntity> allFiles = [];
  List<FileSystemEntity> pageFiles = [];

  _SearchFilePageState(this.args);

  @override
  void initState() {
    super.initState();
    initDate();
  }

  initDate() {
    key = args['key'];
    roots = args['roots'];
    historyKeys = SPUtil.getArray('search_history', []);
    controller.value = TextEditingValue(text: key);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            height: MediaQueryData.fromWindow(window).padding.top,
          ),
          UI.searchBar(context, controller, (String k) {
            if (key == k) return;
            setState(() {
              key = k;
              flashListView = true;
            });
          }),
          historySearch(),
          key == null
              ? Container()
              : flashListView
                  ? FutureBuilder(
                      future: startSearch(key, roots),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Expanded(
                              child: Center(
                            child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator()),
                          ));
                        }
                        if (snapshot.hasData) {
                          return handleSearchResult(snapshot);
                        } else {
                          return Expanded(
                              child: Center(
                            child: boldText(snapshot.error.toString()),
                          ));
                        }
                      })
                  : searchListView(),
        ],
      ),
    );
  }

  handleSearchResult(AsyncSnapshot snapshot) {
    if (key != null && !historyKeys.contains(key)) {
      historyKeys.add(key);
      SPUtil.setArray('search_history', historyKeys);
    }
    allFiles.clear();
    allFiles.addAll(snapshot.data);
    if (allFiles.length > PAGE_LENGTH) {
      allFiles = allFiles.sublist(0, PAGE_LENGTH);
      return searchListView();
    } else if (allFiles.length == 0) {
      return InkWell(
          onTap: () {
            if (isDeepSearch) return;
            setState(() {
              roots = [Common.sd];
              isDeepSearch = true;
            });
          },
          child: Container(
            padding: EdgeInsets.only(top: 150),
            child: Column(
              children: <Widget>[
                Image.asset(
                  Constants.NULL,
                  width: 160,
                  height: 160,
                ),
                isDeepSearch
                    ? Text(
                        '点击尝试深度搜索',
                        style: TextStyle(fontSize: 18),
                      )
                    : Text(
                        '空空如也',
                        style: TextStyle(fontSize: 18),
                      )
              ],
            ),
          ));
    }
  }

  searchListView() {
    return MediaQuery.removePadding(
      //removeTop: true,
      child: Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: allFiles.length,
              itemBuilder: (BuildContext context, int index) {
                if (index == PAGE_LENGTH - 1) {
                  return Container(
                    child: Text('默认最多显示$PAGE_LENGTH条哦'),
                    alignment: Alignment.center,
                  );
                }
                return UI.buildFileItem(
                  file: allFiles[index],
                  isCheck: selectedFiles.contains(allFiles[index].path),
                  onChanged: onChange,
                  onTap: onTap,
                );
              })),
      context: context,
    );
  }

  onChange(bool value, FileSystemEntity file) {
    setState(() {
      flashListView = false;
      if (value) {
        selectedFiles.add(file.path);
        filesSize += file.statSync().size;
      } else {
        selectedFiles.remove(file.path);
        filesSize -= file.statSync().size;
      }
    });
  }

  onTap() {}

  static startSearch(String key, List<String> roots) async {
    if (key == '') {
      throw 'Please input key';
    }
    List<FileSystemEntity> res = await compute(wapperGetAllFiles, {
      'keys': [key],
      'roots': roots
    });
    return res;
  }

  historySearch() {
    List<Widget> widgets = [];
    historyKeys.forEach((key) {
      widgets.add(UI.iconTextBtn(null, key, changeSearchKey,
          longPressCall: onChipLongPress));
    });
    widgets = widgets.reversed.toList();
    return Wrap(
      spacing: 8.0, // 主轴(水平)方向间距
      alignment: WrapAlignment.start, //沿主轴方向居中
      children: widgets,
    );
  }

  changeSearchKey(String k) {
    if (k == key) return;
    setState(() {
      flashListView = true;
      key = k;
      controller.value = TextEditingValue(text: key);
    });
  }

  onChipLongPress(String key) {
    setState(() {
      flashListView = false;
      historyKeys.remove(key);
    });
  }
}
