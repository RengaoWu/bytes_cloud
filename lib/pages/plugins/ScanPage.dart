import 'dart:ui';

import 'package:bytes_cloud/core/manager/ShareManager.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanPage extends StatefulWidget {
  ScanPage({Key key}) : super(key: key);

  @override
  _ScanPageState createState() => new _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final double size = UI.DISPLAY_WIDTH * 0.8;
  QrReaderViewController _controller;
  bool hasPermission = false;
  bool flashOn = false;
  bool isScanStop = false;
  String data;
  @override
  void initState() {
    super.initState();
  }

  Future<bool> getPermission() async {
    Map<PermissionGroup, PermissionStatus> permissions =
        await PermissionHandler().requestPermissions([PermissionGroup.camera]);
    if (permissions[PermissionGroup.camera] == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!hasPermission) {
      Future.wait([getPermission()]).then((onValue) {
        if (onValue[0]) {
          setState(() {
            hasPermission = true;
          });
        } else {
          Navigator.pop(context);
        }
      });
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('扫一扫'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          FlatButton(
            onPressed: selectFromPhotos,
            child: Text(
              "相册",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          flashOn ? Icons.flash_off : Icons.flash_on,
        ),
        onPressed: setFlash,
      ),
      body: Container(
        width: UI.DISPLAY_WIDTH,
        height: UI.DISPLAY_HEIGHT * 0.8,
        child: Center(
            child: Stack(children: <Widget>[
          hasPermission
              ? Container(
                  width: size,
                  height: size,
                  child: QrReaderView(
                    width: size,
                    height: size,
                    callback: (controller) {
                      this._controller = controller;
                      _controller.startCamera(onScan);
                    },
                  ))
              : Container(
                  width: size,
                  height: size,
                  color: Colors.grey,
                ),
          isScanStop
              ? Container(
                  width: size,
                  height: size,
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: size / 3,
                    ),
                    onPressed: () {
                      setState(() {
                        isScanStop = false;
                        _controller.startCamera(onScan);
                      });
                    },
                  ))
              : SizedBox()
        ])),
      ),
    );
  }

  /// fixme 这个插件有个BUG，重新打开之后会执行两次 onScan (概率事件喵喵喵)
  void handleScanSuccess(String v) async{
    setState(() {
      data = v;
      isScanStop = true;
      _controller.stopCamera();
    });
    print("handleScanSuccess $data");

    if (isShareURL(data)) {
      Uri uri = Uri.parse(data);
      bool success = await ShareManager.instance.downloadShareFile(uri);
      if(!success){
        String token = await UI.showInputDialog(context, '请输入提取码');
        if(token == null || token.isEmpty) {
          return;
        }
        Fluttertoast.showToast(msg: '开始下载');
        Map<String, String> args = {};
        args.addAll(uri.queryParameters);
        args.addAll({'share_token': token});
        Uri tokenUri = Uri.http(uri.authority, uri.path, args);
        bool success = await ShareManager.instance.downloadShareFile(tokenUri);
        if(!success){
          Fluttertoast.showToast(msg: '下载失败，token错误');
        }
      }
    } else {
      UI.showMessageDialog(context: context, content: Text(data));
    }
  }

  void selectFromPhotos() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final rest = await FlutterQrReader.imgScan(image);
    handleScanSuccess(rest);
  }

  void onScan(String v, List<Offset> offsets) {
    handleScanSuccess(v);
  }

  void setFlash() {
    if (isScanStop) return;
    setState(() {
      flashOn = !flashOn;
    });
    _controller.setFlashlight();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.stopCamera();
    if (_controller != null) _controller = null;
  }
}
