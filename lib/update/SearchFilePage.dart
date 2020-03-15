import 'dart:io';
import 'dart:ui';

import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/utils/FileIoslateMethods.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';
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
  String root;
  String key;
  List<String> historyKeys = [];
  final controller = TextEditingController();
  Set<String> selectedFiles = Set();
  int filesSize = 0;
  Map<String, dynamic> args;

  bool reflashList = true;
  Widget list;
  List<FileSystemEntity> allFiles = [];

  _SearchFilePageState(this.args);

  @override
  void initState() {
    super.initState();
    initDate();
  }

  initDate() {
    key = args['key'];
    root = args['root'];
    historyKeys = SPUtil.getArray('search_history', []);
    controller.value = TextEditingValue(text: key);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          searchBar(),
          historySearch(),
          key == null
              ? SizedBox()
              : reflashList
                  ? FutureBuilder(
                      future: startSearch(key, root),
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
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Expanded(
                                child: Center(
                              child: boldText(snapshot.error.toString()),
                            ));
                          } else {
                            return handleSearchResult(snapshot);
                          }
                        } else {
                          return Text('Empty');
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
    return searchListView();
  }

  searchListView() {
    return MediaQuery.removePadding(
      removeTop: true,
      child: Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: allFiles.length,
              itemBuilder: (BuildContext context, int index) {
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
      reflashList = false;
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

  static startSearch(String key, String root) async {
    if (key == '') {
      throw 'Please input key';
    }
    List<FileSystemEntity> res = await compute(wapperGetAllFiles, {
      'keys': [key],
      'roots': [root]
    });
    return res;
  }

  historySearch() {
    List<Widget> widgets = [];
    historyKeys.forEach((key) {
      widgets.add(
          UI.iconTextBtn(null, key, onChipTap, longPressCall: onChipLongPress));
    });
    widgets = widgets.reversed.toList();
    return Wrap(
      spacing: 8.0, // 主轴(水平)方向间距
      alignment: WrapAlignment.start, //沿主轴方向居中
      children: widgets,
    );
  }

  onChipTap(String k) {
    setState(() {
      reflashList = true;
      key = k;
    });
  }

  onChipLongPress(String key) {
    setState(() {
      reflashList = false;
      historyKeys.remove(key);
    });
  }

  searchBar() => Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQueryData.fromWindow(window).padding.top,
          ),
          child: Container(
            height: 62.0,
            child: new Padding(
                padding: const EdgeInsets.all(6.0),
                child: new Card(
                    child: new Container(
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 5.0,
                      ),
                      Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: new InputDecoration(
                            hintText: '搜索',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (String k) {
                            setState(() {
                              key = k;
                            });
                          },
                          // onChanged: onSearchTextChanged,
                        ),
                      ),
                      IconButton(
                        icon: new Icon(Icons.cancel),
                        color: Colors.grey,
                        iconSize: 18.0,
                        onPressed: () {
                          controller.clear();
                          // onSearchTextChanged('');
                        },
                      ),
                    ],
                  ),
                ))),
          ),
        ),
      );
}
