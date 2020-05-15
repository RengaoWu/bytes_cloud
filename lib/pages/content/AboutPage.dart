import 'package:bytes_cloud/core/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 8,
            top: 24,
            child: BackButton(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: UI.DISPLAY_HEIGHT * 0.3,
            child: Column(
              children: <Widget>[
                Image.asset(Constants.ICON, width: 64,),
                boldText('Bytes Cloud', fontSize: 20),
                boldText('Version 0.0.1',
                    fontSize: 16, fontWeight: FontWeight.normal),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
                child: Text(
              'Copyright © 2019-2020 All Rights Reserved',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            )),
          ),
        ],
      ),
    );
  }
}
