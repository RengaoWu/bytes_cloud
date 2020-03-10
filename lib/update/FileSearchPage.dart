import 'dart:io';
import 'dart:ui';

import 'package:bytes_cloud/common.dart';
import 'package:bytes_cloud/utils/FileIoslateMethods.dart';
import 'package:bytes_cloud/utils/SPUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FileSearchPage extends StatefulWidget {
  Map<String, dynamic> args;
  FileSearchPage(this.args);
  @override
  State<StatefulWidget> createState() => new _FileSearchPageState(this.args);
}

class _FileSearchPageState extends State<FileSearchPage> {
  String root;
  String key;
  List<String> historyKeys = [];
  final controller = TextEditingController();
  Map<String, dynamic> args;

  _FileSearchPageState(this.args);

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
              : FutureBuilder(
                  future: startSearch(key),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      SPUtil.setArray('search_history', historyKeys);
                      return Text(snapshot.data);
                    } else {
                      return Text('Empty');
                    }
                  })
        ],
      ),
    );
  }

  // 不采用_channel
  static startSearch(String key) async {
    List<String> res =
        await compute(wapperGetFiles, {'key': key, 'root': Common().sDCardDir});
    return res.length.toString();
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
