import 'dart:async';
import 'dart:io';

import 'package:bytes_cloud/core/manager/CacheManager.dart';
import 'package:bytes_cloud/entity/CloudFileEntity.dart';
import 'package:bytes_cloud/http/http.dart';
import 'package:bytes_cloud/pages/plugins/MDPage.dart';
import 'package:bytes_cloud/pages/plugins/VideoPlayerPage.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/pages/plugins/PdfReaderPage.dart';
import 'package:bytes_cloud/pages/plugins/GalleryPage.dart';
import 'package:bytes_cloud/utils/OtherUtil.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

import 'Constants.dart';

Widget boldText(String text,
    {FontWeight fontWeight = FontWeight.bold, double fontSize = 14}) {
  return Text(
    text,
    style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
  );
}

class UI {
  /// The height of the toolbar component of the [AppBar].
  static const double kToolbarHeight = 56.0;

  /// The height of the bottom navigation bar.
  static const double kBottomNavigationBarHeight = 56.0;

  /// The height of a tab bar containing text.
  static const double kTextTabBarHeight = 48.0;
  static double DISPLAY_WIDTH;
  static double DISPLAY_HEIGHT;
  static double devicePixelRatio;

  static dpi2px(double size) => size * devicePixelRatio;

  static newPage(BuildContext context, Widget widget) => Navigator.push(
      context, new MaterialPageRoute(builder: (context) => widget));

  static Widget divider({Color color, double padding = 0, double width = 0.5}) {
    return Divider(
      color: color,
      indent: padding,
      endIndent: padding,
      thickness: width,
    );
  }

  static Widget divider2(
      {double left = 0, double right = 0, double height = 0.3}) {
    return Container(
      child: Container(
        color: Colors.grey,
        height: height,
      ),
      padding: EdgeInsets.only(left: left, right: right),
    );
  }

  static appbarBtn(IconData icon,
      {BuildContext context, void call(BuildContext context)}) {
    return Builder(builder: (BuildContext context) {
      return Padding(
          padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
          child: IconButton(
            onPressed: () {
              if (call != null) call(context);
            },
            icon: new Icon(icon),
          ));
    });
  }

  static showProgressDialog<T>(
      {@required BuildContext context,
      Future<T> future,
      String title,
      Function successCall,
      Function failCall}) {
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: FutureBuilder(
              future: future,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // 请求已结束
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    failCall(snapshot.error);
                  } else {
                    successCall(snapshot.data);
                  }
                  Navigator.pop(context);
                  return CircularProgressIndicator();
                } else {
                  // 请求未结束，显示loading
                  return CircularProgressIndicator();
                }
              },
            ),
          );
        });
  }

  @Deprecated('showInputDialog')
  static showMessageDialog(
      {@required BuildContext context,
      String title = '',
      Widget content,
      Map<String, Function> map}) {
    List<Widget> actions = [];
    if (map != null) {
      map.forEach((w, c) {
        actions.add(FlatButton(onPressed: c, child: Text(w)));
      });
    }

    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: content,
            actions: actions,
          );
        });
  }

  static Future<String> showInputDialog(
      BuildContext context, String title) async {
    TextEditingController controller = TextEditingController();
    Widget content = TextField(
      controller: controller,
    );
    return await UI.showContentDialog(context, title, content,
        left: '取消',
        leftCall: () => Navigator.pop(context),
        right: '确定',
        rightCall: () => Navigator.pop(context, controller.text));
  }

  static Future<String> showContentDialog(
      BuildContext context, String title, Widget content,
      {String left,
      Function leftCall,
      String right,
      Function rightCall,
      bool dismiss = true}) async {
    return showDialog<String>(
        context: context,
        barrierDismissible: dismiss,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: boldText(title, fontSize: 18),
            contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: content),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: FlatButton(
                            child: Text(
                              left,
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () => leftCall(),
                          ))),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey,
                  ),
                  Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: FlatButton(
                            child: Text(
                              right,
                              style: TextStyle(color: Colors.blue),
                            ),
                            onPressed: () => rightCall(),
                          )))
                ],
              )
            ],
          );
        });
  }

  static Widget iconTxtBtn(String image, String title, void call(),
      {double fontSize = 14, FontWeight fontWeight = FontWeight.bold}) {
    return InkWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 24,
            height: 40,
            child: Image.asset(image),
          ),
          boldText(
            "$title",
            fontSize: fontSize,
            fontWeight: fontWeight,
          )
        ],
      ),
      onTap: call,
    );
  }

  static bottomSheet(
          {@required BuildContext context,
          @required Widget content,
          double height = 400,
          double radius = 10,
          double padding = 16}) =>
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (BuildContext bc) {
            return SizedBox(
                height: height,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(radius))),
                      child: Container(
                          alignment: Alignment.center, child: content)),
                ));
          });

  //static showCloudBottomSheet

  static chipText(Widget icon, String text, Function call,
      {Function longPressCall}) {
    return InkWell(
      onTap: () => call(text),
      onLongPress: () => longPressCall(text),
      child: Chip(
        label: Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
        avatar: icon == null
            ? null
            : CircleAvatar(
                child: Padding(
                  child: icon,
                  padding: EdgeInsets.all(2),
                ),
                backgroundColor: Color.fromARGB(0x00, 0xff, 0xff, 0xff),
              ),
        backgroundColor: Color.fromARGB(0x66, 0xAA, 0xFF, 0xFF),
      ),
    );
  }

  static Widget buildFileItem(
      {FileSystemEntity file,
      bool isCheck,
      Function onChanged,
      Function onTap}) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());

    return InkWell(
      child: Card(
        child: ListTile(
            leading: selectIcon(file.path, true),
            title: Text(FileUtil.getFileName(file.path)),
            subtitle: Text(
                '$modifiedTime  ${FileUtil.getFileSize(file.statSync().size)}',
                style: TextStyle(fontSize: 12.0)),
            trailing: Checkbox(
              value: isCheck,
              onChanged: (bool value) {
                onChanged(value, file);
              },
            )),
      ),
      onTap: () {
        onTap(file);
      },
    );
  }

  static Widget buildFolderItem({
    FileSystemEntity file,
    Function onTap,
  }) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());

    return InkWell(
      child: Card(
          child: Container(
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: Image.asset('assets/images/folder.png'),
          title: Row(
            children: <Widget>[
              Expanded(child: Text(FileUtil.getFileName(file.path))),
              Text(
                '${_calculateFilesCountByFolder(file)}项',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
          subtitle: Text(modifiedTime, style: TextStyle(fontSize: 12.0)),
          trailing: Icon(Icons.chevron_right),
        ),
      )),
      onTap: () {
        onTap();
      },
    );
  }

  static Widget buildCloudFileItem({
    CloudFileEntity file,
    Function onTap,
    Widget trailing = const SizedBox(),
  }) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(DateTime.fromMillisecondsSinceEpoch(file.uploadTime));

    Widget leading;
    if (FileUtil.isImage(file.fileName)) {
      leading = ExtendedImage.network(
        getPreviewUrl(file.id, UI.dpi2px(40), UI.dpi2px(40)),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        cache: true,
      );
    } else {
      leading = selectIcon(file.fileName, true);
    }

    return InkWell(
      child: ListTile(
        leading: leading,
        title: Text(FileUtil.getFileName(file.fileName)),
        subtitle: Text('$modifiedTime  "', style: TextStyle(fontSize: 12.0)),
        trailing: trailing,
      ),
      onTap: () {
        onTap(file);
      },
    );
  }

  static Widget buildCloudFolderItem({
    CloudFileEntity file,
    int childrenCount,
    Function onTap,
    Widget trailing = const SizedBox(),
  }) {
    String subTitle = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
            .format(DateTime.fromMillisecondsSinceEpoch(file.uploadTime)) +
        '   $childrenCount 项';
    return InkWell(
      child: Container(
        child: ListTile(
          leading: Image.asset('assets/images/folder.png'),
          title: Text(file.fileName),
          subtitle: Text(subTitle, style: TextStyle(fontSize: 12.0)),
          trailing: trailing,
        ),
      ),
      onTap: () {
        onTap();
      },
    );
  }

  // 计算以 . 开头的文件、文件夹总数
  static int _calculatePointBegin(List<FileSystemEntity> fileList) {
    int count = 0;
    for (var v in fileList) {
      if (p.basename(v.path).substring(0, 1) == '.') count++;
    }
    return count;
  }

  // 计算文件夹内 文件、文件夹的数量，以 . 开头的除外
  static int _calculateFilesCountByFolder(Directory path) {
    var dir = path.listSync();
    int count = dir.length - _calculatePointBegin(dir);
    return count;
  }

  static pushToCloud(BuildContext context, int length, int size) {
    String content = '';
    if (length == 0) {
      content = '没有选择任何文件';
    } else {
      content = '开始上传，总共${length}个文件，共${FileUtil.getFileSize(size)}';
    }
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(content)));
  }

  static openFile(BuildContext context, File currentFile,
      {List<FileSystemEntity> files, bool useOtherApp = false}) {
    if (useOtherApp) {
      OpenFile.open(currentFile.path); // 手机其他APP
      return;
    }
    if (FileUtil.isImage(currentFile.path)) {
      UI.newPage(
          context,
          PhotoGalleryPage({
            'current': currentFile,
            'files': files,
          })); // 图片
    } else if (FileUtil.isVideo(currentFile.path)) {
      UI.newPage(context, VideoPlayerPage({'path': currentFile.path})); // 视频
    } else if (FileUtil.isPDF(currentFile.path)) {
      UI.newPage(context, PDFScreen(path: currentFile.path)); // pdf
    } else if (FileUtil.isText(currentFile.path)) {
      UI.newPage(context, MarkDownPage({'path': currentFile.path})); // 文本
    } else if (FileUtil.isMD(currentFile.path)) {
      UI.newPage(context, MarkDownPage({'path': currentFile.path})); // MD
//    } else if (FileUtil.isFileReaderSupport(currentFile)) {
//      UI.newPage(context, FileReaderPage({'path': currentFile.path})); // Android 10 不兼容
    } else {
      OpenFile.open(currentFile.path); // 手机其他APP
    }
  }

  static openCloudFile(BuildContext context, CloudFileEntity current,
      {List<CloudFileEntity> entities}) {
//    File local = File(FileUtil.getDownloadFilePath(current));
//    if (local.existsSync()) {
//      UI.openFile(context, local);
//      return;
//    }
    if (FileUtil.isImage(current.fileName)) {
      UI.newPage(context,
          PhotoGalleryPage({'current': current, 'files': entities})); // 图片
    }
  }

  static Widget selectIcon(String path, bool preview, {double size = 40}) {
    int resFlag = 0; // 图片 1, 视频 2
    String ext = p.extension(path);
    String iconImg = Constants.UNKNOW;

    switch (ext) {
      case '.ppt':
      case '.pptx':
        iconImg = Constants.PPT;
        break;
      case '.doc':
      case '.docx':
        iconImg = Constants.DOC;
        break;
      case '.xls':
      case '.xlsx':
        iconImg = Constants.EXCEL;
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
        iconImg = preview ? path : Constants.IMAGE;
        resFlag = preview ? 1 : resFlag;
        break;
      case '.txt':
        iconImg = Constants.TXT;
        break;
      case '.mp3':
        iconImg = Constants.MP3;
        break;
      case '.wav':
        iconImg = Constants.WAV;
        break;
      case '.flac':
        iconImg = Constants.FLAC;
        break;
      case '.aac':
        iconImg = Constants.AAC;
        break;
      case '.mp4':
        iconImg = Constants.MP4;
        break;
      case '.avi':
        iconImg = Constants.AVI;
        break;
      case '.flv':
        iconImg = Constants.FLV;
        break;
      case '3gp':
        iconImg = Constants.GP3;
        break;
      case '.rar':
        iconImg = Constants.RAR;
        break;
      case '.zip':
        iconImg = Constants.ZIP;
        break;
      case '.7z':
        iconImg = Constants.Z7;
        break;
      case '.psd':
      case '.pdf':
        iconImg = Constants.PSD;
        break;
      default:
        iconImg = Constants.FILE;
        break;
    }
    if (resFlag == 1) {
      return ClipRect(
        child: ExtendedImage.file(
          File(path),
          width: size,
          height: size,
        ),
      );
    } else {
      return Image.asset(
        iconImg,
        width: size,
        height: size,
      );
    }
  }

  static Widget selectPreview(String path, double size) {
    String ext = p.extension(path);
    int resFlag = 0; // 图片 1, 视频 2
    String iconImg = Constants.UNKNOW;
    switch (ext) {
      case '.ppt':
      case '.pptx':
        iconImg = Constants.PPT;
        break;
      case '.doc':
      case '.docx':
        iconImg = Constants.DOC;
        break;
      case '.xls':
      case '.xlsx':
        iconImg = Constants.EXCEL;
        break;
      case '.jpg':
      case '.jpeg':
      case '.png':
        iconImg = "";
        resFlag = 1;
        break;
      case '.txt':
        iconImg = Constants.TXT;
        break;
      case '.mp3':
      case '.wav':
      case '.flac':
      case '.aac':
        iconImg = Constants.MUSIC;
        break;
      case '.mp4':
      case '.avi':
      case '.flv':
      case '3gp':
        //iconImg = Constants.VIDEO;
        resFlag = 2;
        break;
      case '.rar':
      case '.zip':
      case '.7z':
        iconImg = Constants.COMPRESSFILE;
        break;
      case '.psd':
      case '.pdf':
        iconImg = Constants.PSD;
        break;
      default:
        iconImg = Constants.FILE;
        break;
    }
    if (resFlag == 1) {
      return FutureBuilder(
        future: loadImage(<String, dynamic>{'path': path, 'size': size}),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: size,
              height: size,
            );
          }
          if (snapshot.hasData) {
            return snapshot.data;
          }
          return Text('error');
        },
      );
    } else if (resFlag == 2) {
      return SizedBox(width: size, height: size, child: getThumbWidget(path));
    }
    return ExtendedImage.asset(
      iconImg,
      width: size / 2,
      height: size / 2,
      fit: BoxFit.cover,
    );
  }

  static loadImage(Map<String, dynamic> map) async {
    double size = map['size'];
    String path = map['path'];
    return ExtendedImage.file(
      File(path),
      fit: BoxFit.cover,
      width: size,
      height: size,
    );
  }

  static searchBar(BuildContext context, TextEditingController controller,
          Function submit) =>
      Container(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: EdgeInsets.only(
              top: 0,
            ),
            child: Container(
              height: UI.kToolbarHeight,
              child: new Padding(
                  padding: const EdgeInsets.all(2),
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
                            style: TextStyle(fontSize: 15),
                            decoration: new InputDecoration(
                              hintText: '搜索',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (String k) {
                              submit(k);
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
          ));
  static leftTitle(String title,
      {double paddingLeft = 8,
      double paddingTop = 0,
      double paddingRight = 0,
      double paddingBottom = 0,
      double size = 18,
      FontWeight fontWeight = FontWeight.bold}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          paddingLeft, paddingTop, paddingRight, paddingBottom),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: size, fontWeight: fontWeight),
        ),
      ),
    );
  }

  static showSnackBar(BuildContext context, Widget content,
      {Duration duration = const Duration(seconds: 1)}) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: content,
      duration: duration,
    ));
  }

  // flag = 1 just year
  // flag = 2 year and month
  // flag = 3 year month day
  static Widget groupItemCard(DateTime dateTime, {int flag = 2}) {
    String content = '';
    if (flag == 1) {
      content = '${dateTime.year} 年';
    } else if (flag == 2) {
      content = '${dateTime.year} 年 ${dateTime.month} 月 ';
    } else {
      content = '${dateTime.year} 年 ${dateTime.month} 月 ${dateTime.day} 日';
    }
    return Container(
      margin: const EdgeInsets.all(4),
      child: Text(
        '-  $content -',
        style: TextStyle(fontSize: 15, color: Colors.black38),
      ),
      alignment: Alignment.center,
    );
  }

  static iconTxtListItem(String icon, String content, Widget tail, Function tap,
      {double top = 0, double left = 0, double right = 0, double bottom = 0}) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.fromLTRB(left, top, right, bottom),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Image.asset(
                icon,
                width: 24,
              ),
            ),
            Expanded(child: boldText(content)),
            tail != null ? tail : SizedBox()
          ],
        ),
      ),
      onTap: tap,
    );
  }
}
