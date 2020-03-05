import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<String> getHttp() async {
  try {
    Response response = await Dio().get("http://www.baidu.com");
    return response.data;
  } catch (e) {
    return e.toString();
  }
}

class HttpTestRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HttpTestRouteState();
  }
}

class HttpTestRouteState extends State<HttpTestRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: FutureBuilder(
        future: getHttp(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return Text(snapshot.data);
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    ));
  }
}
