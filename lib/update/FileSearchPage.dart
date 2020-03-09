import 'dart:ui';

import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FileSearchPage extends StatefulWidget {
  String root;
  FileSearchPage(this.root);
  @override
  State<StatefulWidget> createState() => new _FileSearchPageState(root);
}

class _FileSearchPageState extends State<FileSearchPage> {
  String root;
  String key;
  List<String> historyKeys = [];
  final controller = TextEditingController();
  MethodChannel _channel = MethodChannel(Constants.FILE_CHANNEL);

  _FileSearchPageState(this.root);

  @override
  void initState() {
    super.initState();
    initDate();
  }

  initDate() {
    historyKeys = SPUtil.getArray('search_history', ['1', '2']);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          searchBar(),
          historySearch(),
          FutureBuilder(
              future: startSearch(key),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Text(snapshot.data);
                } else {
                  return Text('Error');
                }
              })
        ],
      ),
    );
  }

  // 不采用_channel
  Future<String> startSearch(String key) {
//    final Map<String, dynamic> args = <String, dynamic>{'key': key};
//    _channel.invokeListMethod('searchFile', args);
  }

  historySearch() {
    List<Widget> widgets = [];
    historyKeys.forEach((key) {
      widgets.add(UI.iconTextBtn(null, key, onClickSearchHistoryBtn));
    });
    return Wrap(
      spacing: 8.0, // 主轴(水平)方向间距
      alignment: WrapAlignment.start, //沿主轴方向居中
      children: widgets,
    );
  }

  onClickSearchHistoryBtn(String key) {}

  searchBar() => Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQueryData.fromWindow(window).padding.top,
          ),
          child: Container(
            height: 60.0,
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
