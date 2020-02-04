import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'SearchRoute.dart';

class CloudRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CloudRouteState();
  }
}

class CloudRouteState extends State<CloudRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Cloud'),
        ),
        body: Column(
          children: <Widget>[
            getSearchWidget(),
          ],
        ));
  }

  Widget getSearchWidget() {
    return Center(
        child: Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: () {
                showSearch(context: context, delegate: SearchBarDelegate());
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  Text(
                    'Search',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.sort,
            color: Colors.grey,
          )
        ],
      ),
    ));
  }

  Widget getFileListWidget() {
    return null;
  }
}
