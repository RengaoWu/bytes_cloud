import 'package:bytes_cloud/http/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RemoteRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RemoteRouteState();
  }
}

class RemoteRouteState extends State<RemoteRoute>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.widgets),
          onPressed: () {
            // http://116.62.177.146:5000/api/file/all?curUid=0
            httpGet('/api/file/all', {'curUid': '0'}).then((value) {
              print(value);
            });
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.transform),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {},
          )
        ],
      ),
      body: Container(),
    );
  }

  @override
  bool get wantKeepAlive => false;

  @override
  void dispose() {
    super.dispose();
    print('remote route dispose');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('remote route deactivate');
  }
}
