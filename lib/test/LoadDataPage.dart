import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
    runApp(new SampleApp());
}

class SampleApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'Sample App',
            theme: new ThemeData(
                primarySwatch: Colors.blue,
            ),
            home: new SampleAppPage(),
        );
    }
}

class SampleAppPage extends StatefulWidget {
    SampleAppPage({Key key}) : super(key: key);

    @override
    _SampleAppPageState createState() => new _SampleAppPageState();
}

class _SampleAppPageState extends State<SampleAppPage> {
    List widgets = [];

    @override
    void initState() {
        super.initState();
        loadData();
    }

    showLoadingDialog() {
        if (widgets.length == 0) {
            return true;
        }

        return false;
    }

    getBody() {
        if (showLoadingDialog()) {
            return getProgressDialog(); // 网络请求没有返回，显示加载指示器
        } else {
            return getListView(); // 数据加载出来了
        }
    }

    getProgressDialog() {
        return new Center(child: new CircularProgressIndicator());
    }

    @override
    Widget build(BuildContext context) {
        return new Scaffold(
                appBar: new AppBar(
                    title: new Text("Sample App"),
                ),
                body: getBody());
    }

    ListView getListView() => new ListView.builder(
            itemCount: widgets.length,
            itemBuilder: (BuildContext context, int position) {
                return getRow(position);
            });

    Widget getRow(int i) {
        return new Padding(padding: new EdgeInsets.all(10.0), child: new Text("Row ${widgets[i]["title"]}"));
    }

    loadData() async {
        String dataURL = "https://jsonplaceholder.typicode.com/posts";
        http.Response response = await http.get(dataURL);
        setState(() {
            //widgets = JSONU.decode(response.body);
            widgets = [{'title' : '1'}];
        });
    }
}